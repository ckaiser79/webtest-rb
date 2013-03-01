
require 'sz'
require 'webtest/files'
require 'fileutils'

require 'rspec'
require 'rspec/core/runner'
require 'wtac'
require 'sz/issue_definition_context'
require 'pry'

module Webtest

	class RspecTestEngine
		
		attr_writer :testcaseSpec
		
		def initialize
			@fileName = "/spec.rb"
		end
		
		def runTest(out, err)
		
			RSpec::configuration.error_stream = nil
			RSpec::configuration.output_stream = nil
			
			args = [
				"--format",
				"nested",
				@testcaseSpec
			]
            
            WTAC.instance.log.debug "run rspec " + args.to_s
			return RSpec::Core::Runner.run(args, out, err)
		
		end
	end

	class Testrunner
			
		include Webtest
		
		attr_accessor :logDir
		attr_accessor :testcaseDir		
		
		def self.validTestcase?(testcaseDir)
		
			# TODO may remove this later
			log = WTAC.instance.log
            log.debug "validTestcase?: testcaseDir set? " + (testcaseDir != nil).to_s
			log.debug "validTestcase?:  spec.rb exists? " + File.exists?(testcaseDir + "/spec.rb").to_s
			log.debug "validTestcase?: spec.yml exists? " + File.exists?(testcaseDir + "/spec.yml").to_s
		
			result = testcaseDir != nil		
			result = result && File.exists?(testcaseDir + "/spec.rb") 		
			
			return result
		end
		
		def initialize
			@executionResult = "NOT EXECUTED"
			@configureTestEngineAdvice = ConfigureTestEngineAdvice.new
		end
		
		def valid?			
			return Webtest::Testrunner.validTestcase?(@testcaseDir)
		end
		
		def run
            doRun
        end
		
		def testcaseName
			return "<unknown-testcase>" if @testcaseDir == nil
			/\/?([^\/]+)\/?$/.match(@testcaseDir)
			return $1
		end
	
		def to_s
			return testcaseName() + " [" + @executionResult + "]"
		end
	
		protected
		
        def doRun
        	
			WTAC.instance.log.info "FOO"
			
			advice = AssertValidDirectoriesAndCreateThemAdvice.new
			advice.testcaseDir = @testcaseDir
			advice.logDir = @logDir
			advice.onBefore
			
			WTAC.instance.log.info "BAR"
			
			advice = LoadTestcaseSpecificConfigurationAdvice.new
			advice.testcaseDir = @testcaseDir
			advice.onBefore
            
			@configureTestEngineAdvice.testcaseDir = @testcaseDir
			@configureTestEngineAdvice.onBefore
			
            advice = ConfigureTestcaseLoggingAdvice.new
			advice.logDir = @logDir
			advice.onBefore
			
			rspecLogfilesOpenAndCloseAdvice = RspecLogfilesOpenAndCloseAdvice.new
			rspecLogfilesOpenAndCloseAdvice.logDir = @logDir
			rspecLogfilesOpenAndCloseAdvice.onBefore			
						
			advice = ExecuteTestcaseAdvice.new
			advice.testEngine = @configureTestEngineAdvice.testEngine
			advice.out = rspecLogfilesOpenAndCloseAdvice.out
			advice.err = rspecLogfilesOpenAndCloseAdvice.err
			advice.onInvoke			
			@executionResult = advice.executionResult
			
			advice = ExecuteTestcaseIssuesAdvice.new
			advice.testcaseDir = @testcaseDir			
			advice.executionResult = @executionResult
			advice.testEngine = @configureTestEngineAdvice.testEngine
			advice.logDir = @logDir
			advice.onReturn
			@executionResult = advice.executionResult
						
			advice = LogTestcaseSourcesAdvice.new
			advice.logDir = @logDir
			advice.testcaseDir = @testcaseDir
			advice.onReturn
			
			advice = CloseBrowsersAdvice.new
			advice.onReturn
					
			rspecLogfilesOpenAndCloseAdvice.onReturn
						
			advice = TestrunConfigAndFileHandleCleanupAdvice.new
			advice.onReturn
			
		end

	end
    
    class ContextAwareTestrunner < Testrunner
            
        def run
            if isContextAvailable
                @logDir = @logDir + "/" + Webtest::TestcaseContext.instance.name.to_s 
            end
            
            super

        end
        
		def to_s
            if isContextAvailable
                name = " @ " + Webtest::TestcaseContext.instance.name.to_s
            else
                name = ""
            end
			return testcaseName() + name + " [" + @executionResult + "]"
		end
        
        def isContextAvailable
            return Webtest::TestcaseContext.instance.name != Webtest::TestcaseContext::DEFAULT_CONTEXT_NAME
        end
    end
	
	class TestrunConfigAndFileHandleCleanupAdvice
	
		def onReturn(result = nil, error = nil)
			closeFilesAndLocalConfig
		end
		
		def onThrows(error = nil)
			closeFilesAndLocalConfig
		end
		
		private
		
		def closeFilesAndLocalConfig
		
			ac = WTAC.instance
		
			Webtest::Files.closeAll()
            Webtest::Files.flushAll()

			ac.config.loadLocal(nil)
			ac.log.localLogger = nil
		end
	end
	
	class RspecLogfilesOpenAndCloseAdvice
		
		attr_writer :logDir
		attr_writer :suffix
		
		attr_reader :out
		attr_reader :err
	
		def onBefore
		
			if(@suffix != nil)
				@out = Webtest::Files::openWriteCreate(@logDir + "/rspec-stdout" + @suffix.to_s + ".txt")
				@err = Webtest::Files::openWriteCreate(@logDir + "/rspec-stderr" + @suffix.to_s + ".txt")
			else
				@out = Webtest::Files::openWriteCreate(@logDir + "/rspec-stdout.txt")
				@err = Webtest::Files::openWriteCreate(@logDir + "/rspec-stderr.txt")			
			end
		end
	
		def onReturn(result = nil, error = nil)
			closeFiles
		end
		
		def onThrows(error = nil)
			closeFiles
		end
		
		private 
		
		def closeFiles
			Webtest::Files.close(@out)
			Webtest::Files.close(@err)
		end
	
	end
	
	class CloseBrowsersAdvice
	
		include Webtest
	
		def onReturn(result = nil, error = nil)
			closeBrowsersOnDemand
		end
		
		def onThrows(error = nil)
			closeBrowsersOnDemand
		end
		
		private 
		
		def closeBrowsersOnDemand
			config = WTAC.instance.config
			
			if true?(config.read('browser-tests:autocloseBrowser'))
				BrowserInstanceService.instance.closeOwnBrowsers
			end
		end
		
	end
	
	class LogTestcaseSourcesAdvice
	
		attr_writer :logDir
		attr_writer :testcaseDir
	
		def onReturn(result = nil, error = nil)
			logTestcaseSource
		end	

		def onThrows(error = nil)
			logTestcaseSource
		end	

		private 
		
		def logTestcaseSource
			src = @logDir + '/src'
			if not File.directory?(src)
				FileUtils.mkdir src
			end
			FileUtils.cp_r Dir.glob(@testcaseDir + '/*'), src
		end
	
	end
	
	class ExecuteTestcaseIssuesAdvice
		
		attr_accessor :executionResult
		attr_writer :testcaseDir
		attr_writer :testEngine
		attr_writer :logDir
		
		def initialize
		
			@executeTestcaseAdvice = ExecuteTestcaseAdvice.new
			
		end
		
		def onReturn
			
			if @executionResult == "FAIL"
			
				@executeTestcaseAdvice.testEngine = @testEngine
				binding.pry
				# scan for known issues and rerun each issue
				Dir[@testcaseDir + '/spec*.rb'].each do |file|
					
					executeIssueFileSpec(file)
				end
			end
			
		end
        
		def executeIssueFileSpec(file)
			# find issue name
			file =~ /^.+\/spec[-_\s]+(.+)\.rb$/
			issueName = $1
			
			if issueName != nil
				
				issue = SZ::IssueDefinitionContext.instance.create(issueName)
				WTAC.instance.log.info("Check for issue " + issue.to_s)
			
				rspecLogfilesOpenAndCloseAdvice = RspecLogfilesOpenAndCloseAdvice.new
				rspecLogfilesOpenAndCloseAdvice.logDir = @logDir
				rspecLogfilesOpenAndCloseAdvice.suffix = issue.to_s
				rspecLogfilesOpenAndCloseAdvice.onBefore
			
				@testEngine.testcaseSpec = file
				
				@executeTestcaseAdvice.out = @rspecLogfilesOpenAndCloseAdvice.out
				@executeTestcaseAdvice.err = @rspecLogfilesOpenAndCloseAdvice.err
				@executeTestcaseAdvice.suffix = issue.to_s
				@executeTestcaseAdvice.onInvoke
				
				rspecLogfilesOpenAndCloseAdvice.onReturn
				
				rc = @executeTestcaseAdvice.rc
				issue.markDetected if(rc == 0)
				
				@executionResult = @executeTestcaseAdvice.executionResult				
			
			end			
		end		
	end
	
	class ExecuteTestcaseAdvice
	
		include Webtest
	
		RC_TESTENGINE_THROWS_EXCEPTION = -1
	
		attr_writer :suffix
		attr_writer :testEngine
		
		attr_writer :out
		attr_writer :err
		
		attr_reader :executionResult
	
		def onInvoke
			executeTestEngine
		end
		
		private
			
		def executeTestEngine
			ac = WTAC.instance
			
			rc = RC_TESTENGINE_THROWS_EXCEPTION
			
			begin
				rc = @testEngine.runTest(@out,@err)
			rescue Exception => e
				ac.log.warn("Testengine throws exception: " + e.message)	
				ac.log.warn("Dump stacktrace:\n" + e.backtrace.join("\n"))
				
				@executionResult = "FAIL BY EXCEPTION (" + e.message + ")"
			end
			
			setTestcaseResult(rc)
	
			if true?(ac.config.read('browser-tests:autocloseBrowser'))
				BrowserInstanceService.instance.closeOwnBrowsers
			end
		end

		def setTestcaseResult(rc)
			
			WTAC.instance.log.debug("rc = " + rc.to_s)
					
			if(rc != 0)
				@executionResult = "FAIL"
			else
				@executionResult = "SUCCESS"
			end
		end
		
	end

	class LoadTestcaseSpecificConfigurationAdvice
	
		attr_writer :testcaseDir
	
		def onBefore
			ac = WTAC.instance
			if File.exists?(@testcaseDir + "/spec.yml")
				ac.config.loadLocal(File.open(@testcaseDir + "/spec.yml"))
			else
				ac.config.loadLocal(nil)
			end
		end
	
	end
	
	class AssertValidDirectoriesAndCreateThemAdvice

		attr_writer :testcaseDir
		attr_writer :logDir
	
		def onBefore
			if(!Webtest::Testrunner.validTestcase?(@testcaseDir))
				raise "Invalid testcase specification. Does spec.yml and spec.rb exist?"
			end
            
			WTAC.instance.log.debug "logDir '" + @logDir + "'" 
			FileUtils::mkdir_p(@logDir)		
		end
			
	end
	
	class ConfigureTestcaseLoggingAdvice
	
		include Webtest
		attr_writer :logDir
	
		def onBefore
				
			ac = WTAC.instance
            logfile = Webtest::Files.openWriteCreate(@logDir + '/run.log')
			log = Logger.new(logfile)
					
			stdoutLog = Logger.new(STDOUT)
			stdoutLog.level = Logger::INFO
			
			decoratedLog = SecondLoggerDecorator.newPassthroughLogger(log, stdoutLog)
            
			if(true?(ac.config.read("main:verbose")))
				decoratedLog.level = Logger::DEBUG
			else
				decoratedLog.level = Logger::INFO
			end
            
			ac = WTAC.instance
			ac.log.localLogger = decoratedLog
			ac.log.sendToBoth = false
            
			SZ::NumericPrefixGenerateService.instance.directoryPrefix = @logDir
		end
	
	end

	class ConfigureTestEngineAdvice
	
		attr_reader :testEngine
		attr_writer :testcaseDir
	
		def initialize
			@testEngine = Webtest::RspecTestEngine.new
		end
	
		def onBefore			
			@testEngine.testcaseSpec = @testcaseDir + '/spec.rb'
		end
	end
	
end
