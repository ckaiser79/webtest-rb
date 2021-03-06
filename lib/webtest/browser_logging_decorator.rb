
require 'sz'
require 'watir-webdriver'
require 'decorator'

module Webtest

	class BrowserAssertionError < StandardError
	
	
	end

	class LoggingProxy
		
		attr_writer :log
		attr_writer :excludes
		
		def initialize(target)
			@target = target
			@excludes = Array.new

			@excludes.push "to_s"
			@excludes.push "inspect?"
			@excludes.push "html"
		end
		
		def method_missing(method, *args, &block)			
			
			# does not worked in decorated environments in ruby
			#isPublic = @target.respond_to? method			
			#if isPublic
			#end
			
			if(!@excludes.include?(method.to_s))
				shortName = @target.class.name.gsub(/^.*::/,'')
				msg = "Invoke " + shortName + "#" + method.to_s + " " + args.to_s
				
				if @log != nil
					@log.info msg
				else
					puts msg
				end
			end
			
			@target.send(method, *args, &block)
		end
		
	end

	class BrowserWithCacheAccess

		include Decorator
	
		def clearCache
			WTAC.instance.log.info("Clear cache is not available")
			#Watir::CookieManager::WatirHelper.deleteSpecialFolderContents(Watir::CookieManager::WatirHelper::COOKIES) 
			#Watir::CookieManager::WatirHelper.deleteSpecialFolderContents(Watir::CookieManager::WatirHelper::INTERNET_CACHE) 
		end

	end
	
	class BrowserWithBaseUrl
		include Decorator
		
		attr_accessor :baseUrl
		
		def goto(url)
			if url.index('://')!= nil
				return super(url)
			else
				return super(@baseUrl + url)
			end
		end
		
	end
	
	class WaitingBrowserDecorator
	
		include Decorator	
		
		def initialize(decorated)
			@decorated = decorated
		end
		
		def waitFor(spec, defaultTimeout = 5)
			i = 0
			until browser.element(spec).exists? do 
				if i > defaultTimeout 
					raise 'Element ' + spec.to_s + ' is not available after ' + defaultTimeout.to_s + ' sec.'
				end
				sleep 1
				i = i + 1
			end
		end
	
	end
	
	class BrowserWithDumper
	
		include Decorator
	
		attr_writer :dumpOnInspection
		
		def dumpOnInspection?
			return @dumpOnInspection
		end
			
		def initialize(decorated)
			@decorated = decorated
			
			config = WTAC.instance.config
			@selectedBrowserType = config.read('browser-tests:browser-type')
			
			@filenameGenerateService = SZ::NumericPrefixGenerateService.instance
			
			@dumpOnInspection = false
		end	

		def dump(name = nil)

			filename = @filenameGenerateService.nextFilename "png", name
			WTAC.instance.log.info('Dump page screenshot and source ' + filename)
			
			begin
				@decorated.driver.save_screenshot filename
			rescue Exception => e
				WTAC.instance.log.warn('Unable to dump screenshot for ' + filename)
				WTAC.instance.log.warn(e.message + "\n" + e.backtrace.join("\n"))
			end
			
			filename = @filenameGenerateService.lastFilename "html"			
			begin
				htmlSource = @decorated.html 
				file = File.open(filename, File::WRONLY | File::CREAT)
				file.puts htmlSource
				file.close
			rescue Exception => e
				WTAC.instance.log.warn('Unable to dump html source for ' + filename)
				WTAC.instance.log.warn(e.message + "\n" + e.backtrace.join("\n"))
			end
			
		end
		
	end

end
