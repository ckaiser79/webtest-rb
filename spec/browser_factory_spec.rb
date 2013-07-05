
require 'webtest'
require 'pry'

describe Webtest::BrowserFactory, "#newBrowser" do

	before :each do
		config = Webtest::Configuration.new
		config.loadGlobal("
---
browser-tests:
  browser-type: ff
  x-size: 800
  y-size: 600
") 

		WTAC.instance.config = config
		@factory = Webtest::BrowserFactory.new
		
	end
	
	it "should generate a new browser object" do
		
		browser1 = @factory.newBrowser
		browser1.should_not be_nil 
		
		browser2 = @factory.newBrowser
		browser2.should_not == browser1
		
		browser1.close
		browser2.close
	end
		
	it "should return borwser based on configuration" do
	
		WTAC.instance.config.loadLocal("
---
browser-tests:
  browser-type: chrome
")	
		@factory = Webtest::BrowserFactory.new
		browser = @factory.newBrowser
		browser.close
	end
	
	it "should throw an exception, if browser is not supported" do		
		WTAC.instance.config.loadLocal("
---
browser-tests:
  browser-type: bad_browser
")

		@factory = Webtest::BrowserFactory.new
		expect { browser = @factory.newBrowser }.to raise_error
	end
	
end
