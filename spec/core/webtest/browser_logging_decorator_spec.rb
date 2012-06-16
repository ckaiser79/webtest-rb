
$LOAD_PATH << '../../../lib/core'

require 'webtest'

describe Webtest::BrowserLoggingDecorator, "#newBrowser" do

	before :each do
		config = Webtest::Configuration.new
		config.loadGlobal("
---
browser-tests:
  browser-type: ff
") 

		WTAC.instance.config = config
		
		factory = Webtest::BrowserFactory.new
		browser = factory.newBrowser
		
		@decoratedBrowser = BrowserLoggingDecorator.new(browser)
		@decoratedBrowser.logDir '../../log'
		
	end

	it "can enable or disable dumpOnInspection" do
		@decoratedBrowser.dumpOnInspection = true
		@decoratedBrowser.dumpOnInspection = false
	end
	
	it "should dump screenshots and html source" do
		
		@decoratedBrowser.dump
		@decoratedBrowser.dump "foobar"
		
	end
	
end