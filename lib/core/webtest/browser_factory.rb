
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
		attr_writer :reuseBrowser
	
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
			
			sizeX = config.read('browser-tests:x-size').to_i
			sizeY = config.read('browser-tests:y-size').to_i
			
			service = Webtest::BrowserInstanceService.instance
			service.selectedBrowserType = @selectedBrowserType
			service.sizeX = sizeX
			service.sizeY = sizeY
			
			@lastBrowserInstance = nil
			@reuseBrowser = false
		end
	
		def newBrowser(mayReuse = true)
		
			if mayReuse || @reuseBrowser
				if @lastBrowserInstance == nil
					@lastBrowserInstance = createNewSelfDestructingBrowser
				end
			else
				@lastBrowserInstance = createNewSelfDestructingBrowser
				@@openBrowsers.push @lastBrowserInstance if @autocloseBrowser
			end

			proxy = @lastBrowserInstance
			return proxy
		end
		alias browser newBrowser

		private

		def createNewSelfDestructingBrowser
			proxy = createNewConfiguredBrowserInstance

			# close browser if factory dies
			ObjectSpace.define_finalizer(self, proc { proxy.close unless proxy == nil })

			return proxy
		end

		def createNewConfiguredBrowserInstance
			config = WTAC.instance.config
			
			browser = Watir::Browser.new @selectedBrowserType
			
			browser.window.move_to(0,0)
			browser.window.resize_to(
				config.read('browser-tests:x-size').to_i, 
				config.read('browser-tests:y-size').to_i
			)
			
			decoratedBrowser = BrowserWithDumper.new(browser)
			decoratedBrowser = BrowserWithCacheAccess.new(decoratedBrowser)
			decoratedBrowser = WaitingBrowserDecorator.new(decoratedBrowser)
			
			decoratedBrowser = BrowserWithBaseUrl.new(decoratedBrowser)			
			baseUrl = config.readOptional('browser-tests:baseUrl')
			decoratedBrowser.baseUrl = baseUrl
			
			proxy = LoggingProxy.new(decoratedBrowser)
			proxy.log = WTAC.instance.log
			proxy.excludes = [
				'dump',
				'dumpOnInspection'
			]

			return proxy
		end
		
	end

end

