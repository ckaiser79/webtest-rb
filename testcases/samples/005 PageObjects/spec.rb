
require 'webtest'
require 'webtest-browser'

#
# put this into a vendor project
#
module HeisePages

	class MainPage
			
		include Webtest::Browser::PageObjectSupport
			
		def topHeadlines
			return TopHeadlinesBox.new(@browser)
		end
		
	end

	class NewsStartPage < MainPage
	
		def correctBrowserContent?
			return @browser
				.div(:id => 'logo_bereich')
				.div(:class => 'logo')
				.text == 'News'
		end
		
	end
	
	class TopHeadlinesBox < MainPage
	
		def gotoForen
			contentAsDriver
				.link(:text => 'Foren')
				.click
			return ForenStartPage.new(@browser)
		end
		
		def correctBrowserContent?
			return @browser.html =~ /id="logo_bereich"/m
		end
		
		def contentAsDriver
			return @browser.div(:id => 'logo_bereich')
		end
		
		def mainLogo
			return contentAsDriver.div(:class => 'logo')
		end
		
	end
	
	class ForenStartPage < MainPage
		
		def correctBrowserContent?
			return @browser
				.div(:id => 'logo_bereich')
				.div(:class => 'logo')
				.text == 'Leserforum'
		end
		
	end
end

describe "Walk heise.de page" do

  before :all do
	@browser = Webtest::BrowserInstanceService.instance.sharedBrowser
	@browser.dumpOnInspection = false 
  end

  it "click on links using page objects" do
    
	# open a page and check content
	@browser.goto 'http://www.heise.de'
    	
	textSource = HeisePages::NewsStartPage.new(@browser)
		.topHeadlines
		.gotoForen
		.topHeadlines
		.mainLogo
		.text

    textSource.should eql 'Leserforum'
	
  end

end
