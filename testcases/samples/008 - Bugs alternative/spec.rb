
require 'sz'
require 'webtest'

describe "Walk heise.de page" do

	it "adding some issue definitions to testcase" do
		
		idc = SZ::IssueDefinitionContext.instance
		
		issue = idc.create("Bug 1: mark detected manually", :bug)
		issue.markDetected
		
		issue = idc.create("Bug 2: x == y", :bug)
		issue.expect { "x".should eql "y" }
		
		issue = idc.create("Bug 3: x == x", :bug)
		issue.expect{ "x".should eql "x" }
		
		issue = idc.create("Bug 4: return false", :bug)
		issue.expect{ return false }
		
	end

end
