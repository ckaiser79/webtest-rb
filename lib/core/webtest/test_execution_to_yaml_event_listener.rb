require 'sz'
require 'wtac'
require 'pry'

require 'yaml/store'


module Webtest

	class ExportableTestResult
		attr_accessor :name
		attr_accessor :source
		attr_reader   :events

		def initialize
			@events =Array.new
		end

		def addEvent(eventId, eventResult)
			eventDto = TestResultEvent.new
			eventDto.eventId = eventId
			eventDto.result = eventResult
			@events.push eventDto
		end

		private
		
	end


	class TestResultEvent

		attr_reader   :timestamp
		attr_accessor :eventId
		attr_accessor :result
		
		def initialize
			@timestamp = Time.now
		end
	end


	class TestrunnerEventLogger

		attr_writer :testrunner

		def initialize(fileName)
			@store = YAML::Store.new fileName
			@store.transaction do
				@store['eventlog'] = Array.new
			end 
		end
	
		def onTestExecutionBegins
			dto = createSaveableDto
			dto.addEvent :testexecution_begins, loadReturnCode
			return dto
		end

		def onTestExecutionReturns(dto)
			dto.addEvent :testexecution_returns, loadReturnCode
			appendToLogfile dto
			return dto
		end

		def onTestExecutionException(dto)
			dto.addEvent :testexecution_throws_exception, :error
			appendToLogfile dto
			return dto
		end

		def onTestExecutionInvalid
			dto = createSaveableDto
			dto.addEvent :testexecution_invalid_setup, loadReturnCode
			appendToLogfile dto
			return dto
		end

		private 

		def createSaveableDto

			dto = ExportableTestResult.new
			dto.name = @testrunner.testcaseName
			dto.source = @testrunner.testcaseDir
			return dto
		end

		def appendToLogfile(dto)
			# FIXME implement function

			@store.transaction do
				@store['eventlog'].push dto
			end	

			#puts dto.to_s
			#puts dto.to_yaml
		end
		
		def loadReturnCode
			return :skipped if not @testrunner.valid?

			execResult = @testrunner.executionResult
			return :success if execResult == 'SUCCESS'
			return :fail  if execResult == 'FAIL'
			return :defect  if execResult == 'TODO correct value'

			return :unknown
		end

	end

end
