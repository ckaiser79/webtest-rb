
$LOAD_PATH << '../../../lib/core'

require 'webtest'

describe Webtest::TestcaseLocatorService do

	it "finds all directories with a spec.rb file in a given base directory" do
		locator = Webtest::TestcaseLocatorService.instance
		arr = locator.findTestcases '../../sample-testcases'
		r = arr.join " "
        r.should eql "../../sample-testcases/tc_valid_throws_exception ../../sample-testcases/tc_without_config ../../sample-testcases/valid_testcase"
	end

end