
require 'sz/issue_definition_context'

describe "SZ::IssueDefinition" do

	before :each do
		@issue = SZ::IssueDefinition.new
	end

	it "mark detected as true, if expectation is true" do
		@issue.expect { 2 == 2 }
		@issue.detected?.should eql true
	end

	it "mark detected as false, if expectation is false" do
		@issue.expect { 2 == 3 }
		@issue.detected?.should eql false
	end
	
	it "mark detected as false, if expectation throws error" do
		@issue.expect { raise "xxx" }
		@issue.detected?.should eql false
	end
	
	it "mark detected as false, if at least one expectation failed" do
		@issue.expect { 2 == 3 }
		@issue.expect { 2 == 3 }
		@issue.expect { 3 == 3 }
		@issue.detected?.should eql false
	end
	
	
	it "mark detected as false, if no expectations are defined" do
		@issue.detected?.should eql false
	end
end