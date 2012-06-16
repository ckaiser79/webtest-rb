
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
                "-I", "../../lib/core",
                "-I", "../../lib/vendor",
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
			WTAC.instance.log.debug "valid?: testcaseDir set? " + (@testcaseDir != nil).to_s
			WTAC.instance.log.debug "valid?:  spec.rb exists? " + File.exists?(@testcaseDir + "/spec.rb").to_s
			WTAC.instance.log.debug "valid?: spec.yml exists? " + File.exists?(@testcaseDir + "/spec.yml").to_s
		
			result = @testcaseDir != nil		
			result = result && File.exists?(@testcaseDir + "/spec.rb") 		
			#result = result && File.exists?(@testcaseDir + "/spec.yml")
			
			return result
		end
		
		def run

			assertValidDirectoriesAndCreateThem
			assertValidConfiguration
			configureLogging
			
			ac = WTAC.instance
			if File.exists?(@testcaseDir + "/spec.yml")
				ac.config.loadLocal(File.open(@testcaseDir + "/spec.yml"))
			else
				ac.config.loadLocal(nil)
			end
			
			ac.log.info("Start '" + testcaseName() + "'")
			
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
			end
			
			#
			# cleanup TODO put into own object
			#
			
			BrowserFactory.closeAllBrowsers()
			Webtest::Files.closeAll()		
			
			logTestcaseResult(rc)
					
			Webtest::Files.close(out)
			Webtest::Files.close(err)
				
			ac.config.loadLocal(nil)
			ac.log.localLogger = nil

		end
		
		def testcaseName
			return "<unknown-testcase>" if @testcaseDir == nil
			/\/?([^\/]+)\/?$/.match(@testcaseDir)
			return $1
		end
	
		def to_s
			return testcaseName + " [" + @executionResult + "]"
		end
	
		private
		
		def logTestcaseResult(rc)
			ac = WTAC.instance
			testcaseName = testcaseName()
			if(rc != 0)
				ac.log.error("Result: ==FAIL== '" + testcaseName + "', rc = " + rc.to_s)
				@executionResult = "FAIL"
			else
				ac.log.info("Result: ==SUCCESS== '" + testcaseName + "', rc = " + rc.to_s)
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
			
			FileUtils::mkdir_p(@logDir)
			
		end
		
		def configureLogging
		
			ac = WTAC.instance
			logfile = File.open(@logDir + '/run.log', File::WRONLY | File::CREAT)
			log = Logger.new(logfile)
			
			if(isTrue(ac.config.read("main:verbose")))
				log.level = Logger::DEBUG
				log.debug("Running in debug mode")
			else
				log.level = Logger::INFO
				log.debug("Running in info mode")
			end
		
			stdoutLog = Logger.new(STDOUT)
			stdoutLog.level = Logger::INFO
			
			decoratedLog = SecondLoggerDecorator.newPassthroughLogger(log, stdoutLog)
			
			ac = WTAC.instance
			ac.log.localLogger = decoratedLog
			
			SZ::NumericPrefixGenerateService.instance.directoryPrefix = @logDir
		end
	end
end
