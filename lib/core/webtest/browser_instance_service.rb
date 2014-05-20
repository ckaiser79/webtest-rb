
require 'watir-webdriver'
require 'singleton'

module Webtest

	# 
	# can attach a temporary alternate 
	# logger instead of original one
	#
	class BrowserInstanceService
	
		include Singleton
		include Webtest
	
		attr_accessor :selectedBrowserType
		attr_writer :sizeX
		attr_writer :sizeY
		
		def initialize
			@selectedBrowserType = 'firefox'
			
			@sizeX = 1200
			@sizeY = 800
			
			@lastBrowserInstance = nil
			@spawnedBrowsers = Array.new		
		end
	
		def ownBrowser
			browser = createSelfDestructingBrowser
			@spawnedBrowsers.push browser
			return browser
		end
	
		def sharedBrowser
		
			if not sharedBrowserAvailable?
				browser = createSelfDestructingBrowser									
				@lastBrowserInstance = browser	
			end
			
			return @lastBrowserInstance
		end
		
		def resetSharedBrowser
			if sharedBrowserAvailable?			
				@lastBrowserInstance.clearCache
			end
		end
		
		def closeSharedBrowser
			if sharedBrowserAvailable?			
				@lastBrowserInstance.close
				@lastBrowserInstance = nil
			end
		end
		
		def closeOwnBrowsers
			@spawnedBrowsers.each do |browser|
				if browser != nil and browser.exist?
					browser.close
				end
			end
		end
		
		private
		
		def sharedBrowserAvailable?
			return @lastBrowserInstance != nil && @lastBrowserInstance.exist?
		end

		def createSelfDestructingBrowser
			browser = createNewConfiguredBrowserInstance
			
			# close opened browsers if factory is destroyed
			ObjectSpace.define_finalizer(self, proc { 
				if browser != nil && browser.exist?
					browser.close 
				end
			})
			
			return browser
		end
		
		def createNewConfiguredBrowserInstance
			config = WTAC.instance.config
			
			# temporarily proxy workaround
			# @autor: bassmaja
			# @date: 11.11.2013
			
			if @selectedBrowserType == 'firefox'
				browser = Watir::Browser.new @selectedBrowserType, :profile => 'webtest'
			else
				browser = Watir::Browser.new @selectedBrowserType
			end
			
			
			browser.window.move_to(0,0)
			browser.window.resize_to(@sizeX, @sizeY)
			
			decoratedBrowser = BrowserWithDumper.new(browser)
			decoratedBrowser = BrowserWithCacheAccess.new(decoratedBrowser)
			decoratedBrowser = BrowserWithBaseUrl.new(decoratedBrowser)
			
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
