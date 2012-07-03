
require 'sz'
require 'webtest'

describe "Error TC with known bug" do
    before :all do
        @context = Webtest::TestcaseContext.instance
    end
	
	it "display current context" do
		WTAC.instance.log.debug "Context: " + @context.to_s
		WTAC.instance.log.debug "Context: " + @context.read('value2').to_s
		WTAC.instance.log.debug "Context: " + @context.read('nested1:nested-value1').to_s
	end

end
