
module Webtest
	module Browser
		module PageObjectSupport

			def initialize(browser)
				@browser = browser
				raise "Invalid page content " + self.class.to_s if not correctBrowserContent?
			end

			def correctBrowserContent?
				raise "Overwrite method correctBrowserContent?"
			end
			
			def contentAsDriver
				return @browser
			end

		end
	end
end