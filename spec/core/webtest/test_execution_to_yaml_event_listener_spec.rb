
require 'wtac'
require 'logger'
require 'webtest'
require 'webtest/testrunner'
require 'webtest/test_execution_to_yaml_event_listener'
require 'pry'

LOGDIR = '../log'

class MockedTestrunner < Webtest::Testrunner

	attr_writer :isValid
	attr_accessor :executionResult

	def valid?
		return @isValid
	end

end

describe '#onXYZ Events' do

	before :each do
		cfg = Webtest::Configuration.new
			cfg.loadGlobal("
---
main:
  verbose: false
")
		WTAC.instance.config = cfg
		WTAC.instance.log = Logger.new(STDOUT)

		@runner = MockedTestrunner.new
		@runner.isValid = true
                @runner.testcaseDir = 'testrunsamples/0010 - FOO BAR/'
                @runner.logDir = LOGDIR

		@resultFileName = 'testexecution_to_yaml_event_listener.out.yml'
		@object = Webtest::Txl.new @resultFileName
		@object.testrunner = @runner

	end

	it "logs begin and returns success" do	

		dto = @object.onTestExecutionBegins
		@runner.executionResult = "SUCCESS"
		@object.onTestExecutionReturns dto
		
		out = loadResultAndAssertHeaderValues
		out['eventlog'][0].events.size.should eq 2
		out['eventlog'][0].events[0].eventId.should eq :testexecution_begins
		out['eventlog'][0].events[1].eventId.should eq :testexecution_returns
		out['eventlog'][0].events[0].result.should eq  :unknown
		out['eventlog'][0].events[1].result.should eq  :success
	end

	it "logs begin and returns failure" do	

		dto = @object.onTestExecutionBegins
		@runner.executionResult = "FAIL"
		@object.onTestExecutionReturns dto
		
		out = loadResultAndAssertHeaderValues
		out['eventlog'][0].events.size.should eq 2
		out['eventlog'][0].events[0].eventId.should eq :testexecution_begins
		out['eventlog'][0].events[1].eventId.should eq :testexecution_returns
		out['eventlog'][0].events[0].result.should eq  :unknown
		out['eventlog'][0].events[1].result.should eq  :fail
	end

	it "logs begin and returns known defect" do	
		dto = @object.onTestExecutionBegins
		@runner.executionResult = "SUCCESS"
		@object.onTestExecutionReturns dto
		
		out = loadResultAndAssertHeaderValues
		out['eventlog'][0].events.size.should eq 2
		out['eventlog'][0].events[0].eventId.should eq :testexecution_begins
		out['eventlog'][0].events[1].eventId.should eq :testexecution_returns
		out['eventlog'][0].events[0].result.should eq  :unknown
		out['eventlog'][0].events[1].result.should eq  :success
	end

	it "logs invalid testcase" do	
		@runner.isValid = false
		dto = @object.onTestExecutionInvalid
		
		out = loadResultAndAssertHeaderValues
		out['eventlog'][0].events.size.should eq 1
		out['eventlog'][0].events[0].eventId.should eq :testexecution_invalid_setup
		out['eventlog'][0].events[0].result.should eq  :skipped
	end

	it "logs begin and exception" do	
		dto = @object.onTestExecutionBegins
		@object.onTestExecutionException dto
		
		out = loadResultAndAssertHeaderValues
		out['eventlog'][0].events.size.should eq 2
		out['eventlog'][0].events[0].eventId.should eq :testexecution_begins
		out['eventlog'][0].events[1].eventId.should eq :testexecution_throws_exception
		out['eventlog'][0].events[0].result.should eq  :unknown
		out['eventlog'][0].events[1].result.should eq  :error

	end

	def loadResultAndAssertHeaderValues
		out = YAML::load_file(@resultFileName)	
		out['eventlog'][0].name.should eq '0010 - FOO BAR'
		out['eventlog'][0].source.should eq 'testrunsamples/0010 - FOO BAR/'
		return out
	end
end
