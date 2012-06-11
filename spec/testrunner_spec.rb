
require 'logger'
require 'fileutils'

require '../lib/wtac'
require '../lib/webtest/configuration'
require '../lib/webtest/testrunner'

$LOGDIR = '../log'


class DummyTestEngine < Webtest::RspecTestEngine
	def runTest(out, err)
		return -1
	end
end

describe Webtest::Testrunner, "#valid?" do

	before :each do
		
		log = Logger.new(STDOUT)
		config = Webtest::Configuration.new
		config.loadGlobal(File.open('../conf/webtest.yml'))
		
		@ac = WTAC.instance
		@ac.config = config
		@ac.log = log
		
		@runner = Webtest::Testrunner.new
		@runner.logDir = $LOGDIR
		@runner.testEngine = DummyTestEngine.new
		
	end

	it "true if testcase directory contains every needed file" do		
		@runner.testcaseDir = 'valid_testcase'
		@runner.valid?.should == true
	end
	
	it "returns false if directory does not exist" do
		@runner.testcaseDir = 'xyz_not_exist'
		@runner.valid?.should == false
	end
	
	it "returns false if code is missing" do
		@runner.testcaseDir = 'tc_without_code'
		@runner.valid?.should == false
	end
	
	it "returns false if config is missing" do
		@runner.testcaseDir = 'tc_without_config'
		@runner.valid?.should == false
	end
	
end

describe Webtest::Testrunner, "#run" do
	
	before :each do
		
		log = Logger.new(STDOUT)
		config = Webtest::Configuration.new
		config.loadGlobal(File.open('../conf/webtest.yml'))
		
		@ac = WTAC.instance
		@ac.config = config
		@ac.log = log
		
		@runner = Webtest::Testrunner.new 
		@runner.testEngine = DummyTestEngine.new
		@runner.logDir = $LOGDIR
		
	end
	
	it "creates rspec-stdout and rspec-stderr log files" do
		
		FileUtils::rm_rf($LOGDIR)
		File.exists?($LOGDIR).should == false
	
		@runner.testcaseDir = 'valid_testcase'
		@runner.run
		
		File.exists?($LOGDIR).should == true
		File.exists?($LOGDIR + '/rspec-stdout.txt').should == true
		File.exists?($LOGDIR + '/rspec-stderr.txt').should == true
		
	end
	

end

describe Webtest::Testrunner, "#getTestcaseName" do

	before :each do
		@runner = Webtest::Testrunner.new
		@runner.logDir = $LOGDIR
	end
	
	it "extract the testcase name from a simple directory name" do
	
		@runner.testcaseDir = 'xyz_not_exist'
		@runner.testcaseName.should eql 'xyz_not_exist'
	end

	it "extract the testcase name from directory name without trailing /" do	
		@runner.testcaseDir = '/testcases/xyz_not_exist'
		@runner.testcaseName.should eql 'xyz_not_exist'
	end

	it "extract the testcase name from directory name with trailing /" do		
		@runner.testcaseDir = '/testcases/xyz_not_exist/'
		@runner.testcaseName.should eql 'xyz_not_exist'
	end
end

# TestLogDirectory
# - creates log directory
# - cleanup log directory
# - variants?