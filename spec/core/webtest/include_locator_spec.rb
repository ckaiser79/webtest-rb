
require 'webtest/include_locator'

# start testcase: rspec -I ..\..\..\lib\core include_locator_spec.rb

describe Webtest::IncludeLocator, "evaluate include string" do

	before :each do
		@locator = Webtest::IncludeLocator.new 
	end

	it "returns nil if nothing should be included" do
		msg = "xyz"
		@locator.includedFileName(msg).should eql nil
		@locator.includeFile?(msg).should eql false
	end

	it "returns file name" do
		msg = "$(include:xyz)"
		@locator.includedFileName(msg).should eql 'xyz'
    end
    
    it "returns true if filename should be incl     uded" do
        msg = "$(include:xyz)"
		@locator.includeFile?(msg).should eql true
	end

	it "can handle backslashes" do
		msg ='$(include:../xyz)'		
		@locator.includedFileName(msg).should eql '../xyz'
		@locator.includeFile?(msg).should eql true
	end
    
	it "can handle absolute windows pathes" do
		msg ='$(include:c:\temp\datei.txt)'		
		@locator.includedFileName(msg).should eql 'c:\temp\datei.txt'
		@locator.includeFile?(msg).should eql true
	end    
    
    it "can handle absolute unix pathes" do
		msg ='$(include:/tmp/file.name/.../xyz)'		
		@locator.includedFileName(msg).should eql '/tmp/file.name/.../xyz'
		@locator.includeFile?(msg).should eql true
	end    

	it "can handle backslashes" do
		msg = '$(include:..\xyz)'		
		@locator.includedFileName(msg).should eql '..\xyz'
		@locator.includeFile?(msg).should eql true		
	end

	it "can handle dots in filesname" do
		msg = '$(include:..\xyz.abc.yml)'	
		@locator.includedFileName(msg).should eql '..\xyz.abc.yml'
		@locator.includeFile?(msg).should eql true
	end	
	
end
