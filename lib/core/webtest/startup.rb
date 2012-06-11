#!/usr/bin/env ruby

require 'logger'
require 'singleton'

require 'wtac'
require 'fileutils'

require 'webtest/configuration'
require 'webtest/second_logger_decorator'
require 'webtest/testrunner'


module Webtest
	class Startup

		RUN_LOGFILE = "run.log"

		include Singleton
		include Webtest
		
		attr_reader :config

		def init(yamlConfig)

			@config = Webtest::Configuration.new
			@config.loadGlobal(yamlConfig)

			ac = WTAC.instance
			ac.config = @config

		end

		def run
		
			puts "Started"
			configureLogging

			ac = WTAC.instance
			ac.log.info("Started")

			begin
				abortIfLogDirectoryNotClean
				executeAllSelectedTestcases
			rescue Exception => e
				ac.log.error("Abort TC Run: " + e.message)
			end

			ac.log.info("Stopped")
			ac.close

		end
		
		private
		
		def configureLogging
			
			# TODO quick hack
			logdir = '../' + @config.read("main:logdir")

			FileUtils.rm_rf logdir
			FileUtils.mkdir_p logdir
			
			logfile = File.open(logdir + "/" + RUN_LOGFILE, File::WRONLY | File::CREAT)
			log = Logger.new(logfile)

			if(isTrue(@config.read("main:verbose")))
				log.level = Logger::DEBUG
				log.debug("Running in debug mode")
			else
				log.level = Logger::INFO
				log.debug("Running in info mode")
			end

			stdoutLog = Logger.new(STDOUT)
			stdoutLog.level = Logger::INFO
			
			# TODO buggy: stdout logger hides info from logfile
			decoratedLog = SecondLoggerDecorator.newPassthroughLogger(log, stdoutLog)
			decoratedLog = SecondLoggerDecorator.new(decoratedLog)
			WTAC.instance.log = decoratedLog
			
		end

		def executeAllSelectedTestcases
		
			ac = WTAC.instance
			singleTestcase = ac.config.read("testrun:testcase")
	
			if(singleTestcase != "<empty>")
				executeSingleTestcase(singleTestcase)				
			else
				
				locator = Webtest::TestcaseLocatorService.instance
								
				testcasesHome = '../' + ac.config.read("main:testcase-directory")
				testcasesIncludes = ac.config.read("testrun:includes")				
				
				testcasesIncludes.each do |testcaseDirectory|
				
					testcases = locator.findTestcases testcasesHome + '/' + testcaseDirectory
					
					testcases.each do |testcase| 
							executeSingleTestcase(testcase)
					end
					
				end
			
			end	
			
			#testcases = locator.find(ac.config.read("testrun:include"))
			#for tc in testcases do
			#	ac.log.info("run test " + tc)
			#end
		end
		
		def executeSingleTestcase(singleTestcase)
			
			ac = WTAC.instance
						
			testcasesHome = '../' + ac.config.read("main:testcase-directory")
			logDir = '../' + ac.config.read("main:logdir")
			
			singleTestcase = singleTestcase.gsub(/^#{testcasesHome}\/?/, "")
			ac.log.debug "executeAllSelectedTestcases: singleTestcase = " + singleTestcase + ", testcasesHome=" + testcasesHome;
			
			engine = Webtest::RspecTestEngine.new
			engine.testcaseDir = testcasesHome + "/" + singleTestcase
			
			testrunner = Webtest::Testrunner.new
			testrunner.testcaseDir = testcasesHome + "/" + singleTestcase
			testrunner.testEngine = engine
			testrunner.logDir = logDir + "/" + singleTestcase
			
			ac.log.debug("executeSingleTestcase: testrunner.logDir=" + testrunner.logDir);
			
			if(testrunner.valid?)
				ac.log.info("Start execute test " + testrunner.to_s)
				testrunner.run
				ac.log.info("Finished execute test " + testrunner.to_s)
			else
				ac.log.warn("Selected testcase '" + singleTestcase + "' is invalid (dir = '" + testcasesHome + "').")
			end
		end

		def abortIfLogDirectoryNotClean
		
			logdir = '../' + @config.read("main:logdir")
			Dir.foreach(logdir) do |entry|
				WTAC.instance.log.debug "abortIfLogDirectoryNotClean: directory scan, entry='" + entry + "'"
				raise "Log directory is not clean" unless entry == RUN_LOGFILE or entry == '.' or entry == '..'
			end
			
		end
	end
end
