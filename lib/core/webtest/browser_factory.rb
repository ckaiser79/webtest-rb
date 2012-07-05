
require 'watir-webdriver'

module Webtest

	# 
	# can attach a temporary alternate 
	# logger instead of original one
	#
	class BrowserFactory

		include Webtest
	
		@@openBrowsers = Array.new
		
		attr_reader :selectedBrowserType
		attr_writer :autocloseBrowser
		
		def self.closeAllBrowsers()
			@@openBrowsers.each do |browser| 
				if(browser != nil)
					browser.close
				end
			end
		end
	
		def initialize
		
			config = WTAC.instance.config
			if config.available?('browser-tests:autocloseBrowser')
				@autocloseBrowser = isTrue(config.read('browser-tests:autocloseBrowser'))
			else
				@autocloseBrowser = true
			end
		
			@selectedBrowserType = config.read('browser-tests:browser-type')
			
		end
	
		def newBrowser
			browser = Watir::Browser.new @selectedBrowserType
			
			decoratedBrowser = BrowserWithDumper.new(browser)
			decoratedBrowser = BrowserWithCacheAccess.new(decoratedBrowser)
			
			proxy = LoggingProxy.new(decoratedBrowser)
			proxy.log = WTAC.instance.log
			proxy.excludes = [
				'dump',
				'dumpOnInspection'
			]
			
			@@openBrowsers.push proxy if @autocloseBrowser
			return proxy
		end
		
	end

end
