
require '../lib/webtest'

describe Webtest::TestcaseLocatorService do

	it "finds all directories with a spec.rb file in a given base directory" do
		locator = Webtest::TestcaseLocatorService.instance
		arr = locator.findTestcases '.'
		puts arr.join " "
	end

end