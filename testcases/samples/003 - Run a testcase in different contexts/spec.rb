
require 'webtest/testcase_context'

describe "Run something" do

    before :all do
        @context = Webtest::TestcaseContext.instance
    end

  it "pass something" do
    WTAC.instance.log.info "Context: " + @context.to_s
  end

end
