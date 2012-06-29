
require 'sz'
require 'webtest/files'
require 'fileutils'

require 'rspec'
require 'rspec/core/runner'
require 'wtac'

module Webtest

	class RspecTestEngine
		
		attr_writer :testcaseDir
		
		def runTest(out, err)
		
			RSpec::configuration.error_stream = nil
			RSpec::configuration.output_stream = nil
			testcaseSpec = @testcaseDir + "/spec.rb"
			
			args = [
				"--format",
				"nested",
				testcaseSpec
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
			
			@testEngine.testcaseDir = @testcaseDir
			rc = RC_TESTENGINE_THROWS_EXCEPTION
            
			begin
				rc = @testEngine.runTest(out,err)
			rescue Exception => e
				ac.log.warn("Testengine throws exception: " + e.message)	
				ac.log.warn(e.backtrace)
				
				@executionResult = "FAIL BY EXCEPTION (" + e.message + ")"
			ensure
				 Webtest::TestcaseContext.instance.reset()
			end
			
			#
			# cleanup TODO put into own object
			#
			
			BrowserFactory.closeAllBrowsers()
			Webtest::Files.closeAll()		
			
			setTestcaseResult(rc)
					
			Webtest::Files.close(out)
			Webtest::Files.close(err)
				
			ac.config.loadLocal(nil)
			ac.log.localLogger = nil

		end
        
        private
        
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
			logfile = File.open(@logDir + '/run.log', File::WRONLY | File::CREAT)
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
                @logDir = @logDir + "/" + Webtest::TestcaseContext.instance.name 
            end
            
            super.run
        end
        
		def to_s
            if isContextAvailable
                name = " @ " + Webtest::TestcaseContext.instance.name
            else
                name = ""
            end
			return testcaseName() + name + " [" + @executionResult + "]"
		end
        
        def isContextAvailable
            return Webtest::TestcaseContext.instance.name != Webtest::TestcaseContext::DEFAULT_CONTEXT_NAME
        end
    end
end
