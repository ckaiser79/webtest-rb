
require 'logger'
require '../lib/webtest'

describe Webtest::LoggingProxy, " invoke methods" do

	it "logs messages if public method is called" do
		string = "foobar"
		
		proxiedString = Webtest::LoggingProxy.new(string)
		proxiedString.log = Logger.new(STDOUT)
		
		proxiedString.include?("bar").should == true
	end

end