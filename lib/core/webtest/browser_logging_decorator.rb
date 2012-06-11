
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
				@log.info("Invoke " + shortName + "#" + method.to_s + " " + args.to_s)			
			end
			
			@target.send(method, *args, &block)
		end
		
	end
	
	class BrowserWithAssertions
	
		include Decorator
		
		def html
			if @decorated.dumpOnInspection?
				@decorated.dump 
			end
			return @decorated.html
		end

		def assertTitleMatches(titleRegexp)
			if @decorated.dumpOnInspection?
				@decorated.dump 
			end
			unless titleRegexp.match @decorated.title
				raise Webtest::BrowserAssertionError, "title, is = " + @decorated.title + "', should match /" + titleRegexp.source + "/"
			end
		end
		
		def assertTitleInclude(titleRegexp)
			if @decorated.dumpOnInspection?
				@decorated.dump 
			end
			unless @decorated.title.include? title
				raise Webtest::BrowserAssertionError, "title is = " + @decorated.title + "', should include = '" + title + "'"
			end
		end		
		
		def assertTextMatches(regexp)
			if @decorated.dumpOnInspection?
				@decorated.dump 
			end
			unless regexp.match @decorated.text
				raise Webtest::BrowserAssertionError, "text source should match /" + regexp.source + "/" 
			end
		end
		
		def assertHtmlMatches(regexp)
			if @decorated.dumpOnInspection?
				@decorated.dump 
			end
			unless regexp.match @decorated.html
				raise Webtest::BrowserAssertionError, "html source should match /" + regexp.source + "/"
			end
		end
		
		def assertHtmlInclude(text)
			if @decorated.dumpOnInspection?
				@decorated.dump 
			end
			unless @decorated.html.include? title
				raise Webtest::BrowserAssertionError, "html of page should contain '" + text + "'"
			end
		end
		
		def assertTextInclude(text)
			if @decorated.dumpOnInspection?
				@decorated.dump 
			end
			unless @decorated.html.include? title
				raise Webtest::BrowserAssertionError, "text of page should contain '" + text + "'"
			end
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

	class BrowserWithDumper
	
		include Decorator
	
		attr_writer :dumpOnInspection
		
		def dumpOnInspection?
			return @dumpOnInspection
		end
			
		def initialize(decorated, config = nil)
			@decorated = decorated
			
			config = config ||= WTAC.instance.config
			@selectedBrowserType = config.read('browser-tests:browser-type')
			
			@filenameGenerateService = SZ::NumericPrefixGenerateService.instance
			
			@dumpOnInspection = true
		end	

		def dump(name = nil)
		
			filename = @filenameGenerateService.nextFilename "png", name
			@decorated.driver.save_screenshot filename
			
			filename = @filenameGenerateService.lastFilename "html"			
			htmlSource = @decorated.html 
			file = File.open(filename, File::WRONLY | File::CREAT)
			file.puts htmlSource
			file.close

			WTAC.instance.log.info('Dump page_source ' + filename)
			
		end
		
	end

end
