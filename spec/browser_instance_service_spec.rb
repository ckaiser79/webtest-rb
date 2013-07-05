require 'webtest'
require 'pry'

describe Webtest::BrowserFactory, "#reuse browsers" do

	before :each do
		config = Webtest::Configuration.new
		config.loadGlobal("
---
browser-tests:
  browser-type: ff
") 

		WTAC.instance.config = config
	end
	
	it "use existing browser, after instance is returned" do
				
		service1 = Webtest::BrowserInstanceService.instance
		browser1 = service1.sharedBrowser
		
		service2 = Webtest::BrowserInstanceService.instance
		browser2 = service2.sharedBrowser

		browser1.should == browser2
				
		browser3 = service2.ownBrowser
		browser3.should_not == browser2
		
		service1.closeOwnBrowsers
		service1.closeSharedBrowser
	end
	
	it "return valid browser if old one has been closed" do
		
		service = Webtest::BrowserInstanceService.instance
		browser1 = service.sharedBrowser

		browser1.close
		browser1.exist?.should eq false
		
		browser2 = service.sharedBrowser
		browser2.should_not == browser1
		
		browser1 = service.sharedBrowser
		browser2.should == browser1
		
		service.closeOwnBrowsers
		service.closeSharedBrowser
	end
end