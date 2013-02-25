
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
		
		RC_TESTENGINE_THROWS_EXCEPTION = -1
		
		attr_accessor :logDir
		attr_accessor :testcaseDir
		attr_writer :testEngine
		
		def initialize
			@executionResult = "NOT EXECUTED"
		end
		
		def valid?			

			# TODO may remove this later
			log = WTAC.instance.log
            log.debug "valid?: testcaseDir set? " + (@testcaseDir != nil).to_s
			log.debug "valid?:  spec.rb exists? " + File.exists?(@testcaseDir + "/spec.rb").to_s
			log.debug "valid?: spec.yml exists? " + File.exists?(@testcaseDir + "/spec.yml").to_s
		
			result = @testcaseDir != nil		
			result = result && File.exists?(@testcaseDir + "/spec.rb") 		
			
			return result
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
        
			assertValidDirectoriesAndCreateThem
			assertValidConfiguration
			
			ac = WTAC.instance
			if File.exists?(@testcaseDir + "/spec.yml")
				ac.config.loadLocal(File.open(@testcaseDir + "/spec.yml"))
			else
				ac.config.loadLocal(nil)
			end
            
            configureLogging
			
			out = Webtest::Files::openWriteCreate(@logDir + "/rspec-stdout.txt")
			err = Webtest::Files::openWriteCreate(@logDir + "/rspec-stderr.txt")
			
			@testEngine.testcaseSpec = @testcaseDir + '/spec.rb'
			rc = RC_TESTENGINE_THROWS_EXCEPTION
            
			executeTestEngine
			
			#
			# cleanup TODO put into own object
			#
						
			WTAC.instance.log.debug("rc = " + rc.to_s)
			if @executionResult == "FAIL"
				# scan for known issues and rerun each issue
				Dir[@testcaseDir + '/spec*.rb'].each do |file|
					executeIssueFileSpec(file)
				end
			end
			
			logTestcaseSources						
			autocloseBrowsers
					
			Webtest::Files.close(out)
			Webtest::Files.close(err)
			
			Webtest::Files.closeAll()
            Webtest::Files.flushAll()

			ac.config.loadLocal(nil)
			ac.log.localLogger = nil

		end
        
		def executeIssueFileSpec(file)
			# find issue name
			file =~ /^.+\/spec[-_\s]+(.+)\.rb$/
			issueName = $1
			
			if issueName != nil
				
				issue = SZ::IssueDefinitionContext.instance.create(issueName)
				WTAC.instance.log.info("Check for issue " + issue.to_s)
				
				@testEngine.testcaseSpec = file
				
				rc = executeTestEngine(issue.to_s)
				issue.markDetected if(rc == 0)
			
			end
			
		end
		
		def executeTestEngine(suffix = nil)
			ac = WTAC.instance
			
			out = Webtest::Files::openWriteCreate(@logDir + "/rspec-stdout" + suffix.to_s + ".txt")
			err = Webtest::Files::openWriteCreate(@logDir + "/rspec-stderr" + suffix.to_s + ".txt")
			
			begin
				rc = @testEngine.runTest(out,err)
			rescue Exception => e
				ac.log.warn("Testengine throws exception: " + e.message)	
				ac.log.warn("Dump stacktrace:\n" + e.backtrace.join("\n"))
				
				@executionResult = "FAIL BY EXCEPTION (" + e.message + ")"
			end
			
			setTestcaseResult(rc)
			return rc
		end
		
        private
		
		def autocloseBrowsers
		
			config = WTAC.instance.config
			
			if true?(config.read('browser-tests:autocloseBrowser'))
				BrowserInstanceService.instance.closeOwnBrowsers
			end
		end
		
		def logTestcaseSources
			src = @logDir + '/src'
			if not File.directory?(src)
				FileUtils.mkdir src
			end
			FileUtils.cp_r Dir.glob(@testcaseDir + '/*'), src
		end
        
		def setTestcaseResult(rc)
			if(rc != 0)
				@executionResult = "FAIL"
			else
				@executionResult = "SUCCESS"
			end
		end
		
		def assertValidConfiguration
			raise "No Testengine available" if @testEngine == nil
		end
		
		def assertValidDirectoriesAndCreateThem
			if(!valid?)
				raise "Invalid testcase specification. Does spec.yml and spec.rb exist?"
			end
            
			WTAC.instance.log.debug "logDir '" + @logDir + "'" 
			FileUtils::mkdir_p(@logDir)
		end
		
		def configureLogging
		
			ac = WTAC.instance
            logfile = Webtest::Files.openWriteCreate(@logDir + '/run.log')
			log = Logger.new(logfile)
					
			stdoutLog = Logger.new(STDOUT)
			stdoutLog.level = Logger::INFO
			
			decoratedLog = SecondLoggerDecorator.newPassthroughLogger(log, stdoutLog)
            
			if(isTrue(ac.config.read("main:verbose")))
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
	
	class SingleTestfileRunner
	
		attr_accessor :logDir
		attr_accessor :testcaseDir
		attr_writer :testEngine
		
		def run
		
		end
	end
	
	class Adviceable
	
		attr_writer :beforeAdvices
		attr_writer :onReturnAdvices
		attr_writer :onErrorAdvices
		attr_writer :finallyAdvices
	
		attr_writer :runnable
		
		def initialize
		
			@beforeAdvices = Array.new
			@onReturnAdvices = Array.new
			@onErrorAdvices = Array.new
			@finallyAdvices = Array.new
			
			@runnable = nil
			
		end
		
		def run
		
			error = nil
			result = nil
			
			@beforeAdvices.each do |advice|
				advice.run
			end
		
			begin
				result = runnable.run
			rescue e
				error = e
			end
			
			if(error =! nil)
				@onErrorAdvices.each do |advice|
					advice.run e
				end
			else
				@onReturnAdvices.each do |advice|
					advice.run result
				end
			end
		
		ensure
			@finallyAdvices.each do |advice|
				advice.run result, e
			end
		end
	
	end
end
