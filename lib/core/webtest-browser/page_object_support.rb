module Webtest
  module Browser
    module PageObjectSupport

      def initialize(browser)

        @browser = browser

        name = self.class.to_s.gsub /::/,'-'
        @browser.dump name + "-ctor"

        raise "Invalid page content " + self.class.to_s if not correctBrowserContent?
      end

      def correctBrowserContent?
        raise "Overwrite method correctBrowserContent?"
      end

      def contentAsDriver
        return @browser
      end

      alias :browser :contentAsDriver

      def wait(time)
        time = time * 1000000
        x = 0
        while x < time do
          x += 1
        end
      end

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