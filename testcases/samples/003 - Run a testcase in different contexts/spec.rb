
describe "Run something" do

    before :all do
        #@context = TestContext.instance
        @context = nil
    end

  it "pass something" do
    WTAC.instance.log.info "Context: " + @context.to_s
  end

end
