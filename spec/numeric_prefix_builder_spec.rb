
require '../lib/sz/numeric_prefix_generate_service'

describe SZ::NumericPrefixGenerateService,  "#reset" do
	it "should be resetable to 0" do
	
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset
		builder.directoryPrefix = nil
		
		name = builder.nextString
		name.should start_with "0000-"
		
		name = builder.nextString
		name.should start_with "0001-"
		
		builder.reset
		
		name = builder.nextString
		name.should start_with "0000-"
	end
	
	it "should be resetable to any number" do
	
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset
		builder.directoryPrefix = nil
		
		name = builder.nextString
		name.should start_with "0000-"
		
		name = builder.nextString
		name.should start_with "0001-"
		
		builder.reset 10
		
		name = builder.nextString
		name.should start_with "0010-"
		
	end
	
end

describe SZ::NumericPrefixGenerateService,  "#nextString" do

	it "should generate random names in default configuration" do
	
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset
		builder.directoryPrefix = nil
		
		name = builder.nextString
		name.should start_with "0000-"
		
		name = builder.nextString
		name.should start_with "0001-"
		
		name = builder.nextString
		name.should start_with "0002-"
	end
	
	it "should use user defined names" do
	
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset
		builder.directoryPrefix = nil
		
		name = builder.nextString "foobar"
		name.should eql "0000-foobar"
		
		name = builder.nextString "barfoo"
		name.should eql "0001-barfoo"
	end
	
	it "saves the last generated name" do
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset
		
		name = builder.nextString
		
		lastName = builder.lastString
		name.should eql lastName
		
		lastName = builder.lastString
		name.should eql lastName
		
		lastName = builder.lastString
		name.should eql lastName
	end
end

describe SZ::NumericPrefixGenerateService, "#nextFilename" do

	it "should accept nil file extensions" do
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset
		builder.directoryPrefix = nil
		puts builder.nextFilename
	end
	
	it "should accept own file extensions" do
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset 
		builder.directoryPrefix = nil
		name = builder.nextFilename("jpg")
		
		name.should start_with "0000-"
		name.should end_with ".jpg"
	end
	
	it "should add a directory prefix" do
		builder = SZ::NumericPrefixGenerateService.instance
		builder.reset 
		builder.directoryPrefix = "/tmp";
		name = builder.nextFilename("jpg")
		
		name.should start_with "/tmp/0000-"
		name.should end_with ".jpg"
	end
	
	it "should accept own suffixes" do
		builder = SZ::NumericPrefixGenerateService.instance
		builder.directoryPrefix = nil
		builder.reset
		
		builder.nextFilename(nil, "foobar").should eql "0000-foobar"
		builder.nextFilename("jpg", "foobar").should eql "0001-foobar.jpg"
	end
end