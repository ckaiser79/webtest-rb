
require 'watir-webdriver'

module Webtest

	# 
	# can attach a temporary alternate 
	# logger instead of original one
	#
	class BrowserFactory

		include Webtest
	
		attr_reader :selectedBrowserType
			
		def initialize
		
			config = WTAC.instance.config		
			@selectedBrowserType = config.read('browser-tests:browser-type')			
			
			sizeX = config.read('browser-tests:x-size').to_i
			sizeY = config.read('browser-tests:y-size').to_i
			
			service = Webtest::BrowserInstanceService.instance
			service.selectedBrowserType = @selectedBrowserType
			service.sizeX = sizeX
			service.sizeY = sizeY
			
		end
	
		def newBrowser
			browser = Webtest::BrowserInstanceService.instance.ownBrowser
			return browser
		end
		
		def browser
			return Webtest::BrowserInstanceService.instance.sharedBrowser
		end
		
	end

end

