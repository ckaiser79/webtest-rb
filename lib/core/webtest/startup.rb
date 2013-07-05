#!/usr/bin/env ruby

require 'logger'
require 'singleton'

require 'wtac'
require 'fileutils'
require 'pathname'

require 'webtest/configuration'
require 'webtest/second_logger_decorator'
require 'webtest/testrunner'
require 'webtest/testcase_context'
require 'webtest/testcase_context_loader'
require 'sz'


module Webtest
	class Startup


		include Singleton
		include Webtest
		
		attr_reader :config

		def initialize
			@config = WTAC.instance.config
		end
		
		def run
		
			configureLogging

			ac = WTAC.instance
			ac.log.info("Started")

			abortIfLogDirectoryNotClean
			executeAllSelectedTestcases
			
			ac.log.info("Stopped")
			ac.close

		end
		
		private
		
		def configureLogging
			
			logDir = config.read('main:logdir')
			FileUtils.mkdir_p(logDir)
			
			logfileName = @config.read('main:logfile')
			logfile = File.open(logfileName, File::WRONLY | File::CREAT)
			logfile.sync = true
			log = Logger.new(logfile)

			stdoutLog = Logger.new(STDOUT)
			stdoutLog.level = Logger::INFO
			
			decoratedLog = SecondLoggerDecorator.newPassthroughLogger(log, stdoutLog)
            
			targetLog = SecondLoggerDecorator.new(decoratedLog)
			targetLog.sendToBoth = true
            
			if(isTrue(@config.read("main:verbose")))
				targetLog.level = Logger::DEBUG
				targetLog.debug("Running in debug mode")
			else
				targetLog.level = Logger::INFO
				targetLog.debug("Running in info mode")
			end
            
			WTAC.instance.log = targetLog
			WTAC.instance.log.debug "Test debug mode"

			@testrunnerEventLogger = Webtest::TestrunnerEventLogger.new logfileName + '.yml'
		end

		def executeAllSelectedTestcases
		
			ac = WTAC.instance
			singleTestcase = ac.config.read("testrun:testcase")
	
			if(singleTestcase != "<empty>")
				executeTestcaseWithAllContexts(singleTestcase, false)				
			else
				
				locator = Webtest::TestcaseLocatorService.instance
								
				testcasesHome = ac.config.read("main:testcase-directory")
                                
				testcasesIncludes = ac.config.read("testrun:includes")				
				ac.log.info "Load testcase in " + testcasesIncludes.to_s
                
				testcasesIncludes.each do |testcaseDirectory|
				
					testcases = locator.findTestcases testcasesHome + '/' + testcaseDirectory
					
					testcases.each do |testcase| 
						executeTestcaseWithAllContexts(testcase, true)
					end
					
				end
			
			end	
			
		end
		
		def executeTestcaseWithAllContexts(singleTestcase, useTestcaseDirectoryPrefix)
			
			ac = WTAC.instance
			allAvailableContexts = getAllTestcaseContexts(singleTestcase)
                           
			ac.log.info "allAvailableContexts = " + allAvailableContexts.to_s
			if allAvailableContexts == nil
				executeSingleTestcase(singleTestcase, useTestcaseDirectoryPrefix)
			else
				allAvailableContexts.each do |key,value| 
			    
					Webtest::TestcaseContext.instance.reset
					Webtest::TestcaseContext.instance.name = key
					Webtest::TestcaseContext.instance.contextConfiguration = value

					executeSingleTestcase(singleTestcase, useTestcaseDirectoryPrefix)
				end
			end
            
		end
		
		def executeSingleTestcase(singleTestcase, useTestcaseDirectoryPrefix)
				
			testrunner = buildAndConfigureTestrunner(singleTestcase, useTestcaseDirectoryPrefix)
			ac = WTAC.instance

			@testrunnerEventLogger.testrunner = testrunner

			if(testrunner.valid?)
				ac.log.info("Start execute test " + testrunner.to_s)
				testExecutionEventDto = @testrunnerEventLogger.onTestExecutionBegins
				begin
					testrunner.run
					@testrunnerEventLogger.onTestExecutionReturns testExecutionEventDto
				rescue Exception => e
					ac.log.error("Abort TC Run: " + e.message)
					ac.log.error e.backtrace.join("\n")
					@testrunnerEventLogger.onTestExecutionException testExecutionEventDto
				end
				ac.log.info("Finished execute test " + testrunner.to_s)
			else
				testcasesHome = ac.config.read("main:testcase-directory")
				ac.log.warn("Selected testcase '" + singleTestcase + "' is invalid (testcasesHome = '" + testcasesHome + "').")
				@testrunnerEventLogger.onTestExecutionInvalid
			end

		ensure
			removeTestcaseLogger
			logExecutionResult(testrunner)
		end

		def logExecutionResult(testrunner)
			idc = SZ::IssueDefinitionContext.instance
			if idc.issues.length > 0
				WTAC.instance.log.warn "Result (with issues detected): " +  testrunner.to_s 
				idc.issues.each do |issue|
					WTAC.instance.log.warn "Detected issue: " + issue.to_s if issue.detected?
				end
			else
				WTAC.instance.log.info "Result " +  testrunner.to_s
			end
			
			idc.reset		
		end

		def getAllTestcaseContexts(singleTestcase)
			loader = Webtest::TestcaseContextLoader.new
			loader.testcaseHomeDirectory = testcaseHomeDirectory(singleTestcase)
			return loader.loadAvailableContexts()
		end
        
		def buildAndConfigureTestrunner(singleTestcase, useTestcaseDirectoryPrefix)
			ac = WTAC.instance
			logDir = ac.config.read("main:logdir")		
            		
			testrunner = Webtest::ContextAwareTestrunner.new			
                        
			absoluteTestcasePath = File.expand_path(singleTestcase)
			testcaseLogDir = logDir + "/" + guessTestcaseDirectoryByAbsolutePath(absoluteTestcasePath)
	
			testrunner.logDir = testcaseLogDir

			if useTestcaseDirectoryPrefix
				testcasesHome = ac.config.read("main:testcase-directory")
				ac.log.debug "Using TC Home " + testcasesHome
				singleTestcase = singleTestcase.gsub(/^#{testcasesHome}\/?/, "")

				testrunner.testcaseDir = testcasesHome + "/" + singleTestcase

			else
				testrunner.testcaseDir = singleTestcase
			end

			return testrunner
		end
        
		def testcaseHomeDirectory(singleTestcase)
				
			WTAC.instance.log.info "singleTestcase = " + singleTestcase
			
			if Pathname.new(singleTestcase).absolute?
				return singleTestcase
			else
				testcasesHome = WTAC.instance.config.read("main:testcase-directory")
				return testcasesHome + "/" + singleTestcase
			end
		end

		def removeTestcaseLogger
			log = WTAC.instance.log
			log.sendToBoth = true
			log.localLogger = nil
		end

		def guessTestcaseDirectoryByAbsolutePath(absoluteTestcasePath)
		    
			ac = WTAC.instance
			testcaseHomeDirectory = testcasesHome = ac.config.read("main:testcase-directory")

			result = "tc"

			if absoluteTestcasePath =~ /^(#{testcaseHomeDirectory})\/?(.+)$/i
			result = $2
			end

			ac.log.debug("TC path = " + absoluteTestcasePath);
			ac.log.debug("TC logdir = " + result);

			return result
		end
			
		def abortIfLogDirectoryNotClean
		
			logdir = @config.read("main:logdir")
			WTAC.instance.log.info "Scanning " + logdir
			
			Dir.foreach(logdir) do |entry|
				WTAC.instance.log.debug "abortIfLogDirectoryNotClean: directory scan, entry='" + entry + "'"
				raise "Log directory is not clean" unless 
					entry == Webtest::DEFAULT_RUN_LOGFILE or 
					entry == Webtest::DEFAULT_RUN_LOGFILE + '.yml' or 
					entry == '.' or 
					entry == '..'
			end
		end
	end
end
