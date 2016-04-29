module Webtest
  module Browser
    module PageObjectSupport

      def initialize(browser)

        @browser = browser

        name = self.class.to_s.gsub /::/,'-'
		
		if not correctBrowserContent?
			@browser.dump name + "-ctor-invalid-content"
			raise "Invalid page content, see files '" + name + "-ctor-invalid-content'"
		else
			@browser.dump name + "-ctor"
		end
        
      end

      def correctBrowserContent?
        raise "Overwrite method correctBrowserContent?"
      end

      def contentAsDriver
        return @browser
      end

      alias :browser :contentAsDriver

	  # use sleep instead
      #def wait(time)
        
      def as(requestedType)
        return requestedType.new(@browser)
      end

      #
      # shortcut to @browser.html
      #
      def html
        return @browser.html
      end

    end

  end
end