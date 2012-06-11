
require '../lib/webtest'

describe Webtest::BrowserFactory, "#newBrowser" do

	before :each do
		config = Webtest::Configuration.new
		config.loadGlobal("
---
browser-tests:
  browser-type: ff
") 

		WTAC.instance.config = config
	end

	it "should generate a new browser object" do
		factory = Webtest::BrowserFactory.new
		browser = factory.newBrowser
		expect { browser != nil }
		browser.close
	end
	
	it "should autoclose open browsers" do
	
		factory = Webtest::BrowserFactory.new
		
		factory.newBrowser
		factory.newBrowser.close
		factory.newBrowser
		
		 Webtest::BrowserFactory.closeAllBrowsers
	end
	
	it "should return borwser based on configuration" do
	
		WTAC.instance.config.loadLocal("
---
browser-tests:
  browser-type: chrome
")	
		factory = Webtest::BrowserFactory.new
		browser = factory.newBrowser
		browser.goto "www.heise.de"
		browser.close
	end
	
	it "should throw an exception, if browser is not supported" do		
		WTAC.instance.config.loadLocal("
---
browser-tests:
  browser-type: bad_browser
")

		factory = Webtest::BrowserFactory.new
		expect { browser = factory.newBrowser }.to raise_error
	end
	
end