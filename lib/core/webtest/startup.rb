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


module Webtest
	class Startup

		RUN_LOGFILE = "run.log"

		include Singleton
		include Webtest
		
		attr_reader :config

		def init(yamlString)

			@config = Webtest::Configuration.new
			@config.loadGlobal(yamlString)

			ac = WTAC.instance
			ac.config = @config

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
			
			logdir = @config.read("main:logdir")

			FileUtils.rm_rf logdir
			FileUtils.mkdir_p logdir
			
			logfile = File.open(logdir + "/" + RUN_LOGFILE, File::WRONLY | File::CREAT)
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
               
            if(testrunner.valid?)
                ac.log.info("Start execute test " + testrunner.to_s)
                begin
                    testrunner.run
                rescue Exception => e
                    ac.log.error("Abort TC Run: " + e.message)
                    ac.log.error e.backtrace
                end
                ac.log.info("Finished execute test " + testrunner.to_s)
            else
                ac.log.warn("Selected testcase '" + singleTestcase + "' is invalid (dir = '" + testcasesHome + "').")
            end

        ensure
            removeTestcaseLogger
            WTAC.instance.log.info "Result " +  testrunner.to_s
        end
        
        def getAllTestcaseContexts(singleTestcase)
            loader = Webtest::TestcaseContextLoader.new
            loader.testcaseHomeDirectory = testcaseHomeDirectory(singleTestcase)
            return loader.loadAvailableContexts()
        end
        
        def buildAndConfigureTestrunner(singleTestcase, useTestcaseDirectoryPrefix)
        	ac = WTAC.instance
			logDir = ac.config.read("main:logdir")		
            
            engine = Webtest::RspecTestEngine.new
		
			testrunner = Webtest::ContextAwareTestrunner.new
			testrunner.testEngine = engine
            
            
                        
            if Pathname.new(singleTestcase).absolute?
                testcaseLogDir = logDir + "/" + guessTestcaseDirectoryByAbsolutePath(singleTestcase)
            else
                # should work in most cases. I expect to work with absolute directories
                testcaseLogDir = logDir + "/" + singleTestcase
            end
            
			testrunner.logDir = testcaseLogDir
			
            if useTestcaseDirectoryPrefix
                testcasesHome = ac.config.read("main:testcase-directory")
                ac.log.debug "Using TC Home " + testcasesHome
                singleTestcase = singleTestcase.gsub(/^#{testcasesHome}\/?/, "")
            
                engine.testcaseDir = testcasesHome + "/" + singleTestcase
                testrunner.testcaseDir = testcasesHome + "/" + singleTestcase
			
            else
                engine.testcaseDir = singleTestcase
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
            
            return result
        end
        
		def abortIfLogDirectoryNotClean
		
			logdir = @config.read("main:logdir")
			WTAC.instance.log.info "Scanning " + logdir
			
			Dir.foreach(logdir) do |entry|
				WTAC.instance.log.debug "abortIfLogDirectoryNotClean: directory scan, entry='" + entry + "'"
                raise "Log directory is not clean" unless entry == RUN_LOGFILE or entry == '.' or entry == '..'
			end
		end
	end
end
