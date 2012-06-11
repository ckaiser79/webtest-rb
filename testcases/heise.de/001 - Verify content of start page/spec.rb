
require 'sz'
require 'webtest'

require 'webtest-tc'

describe "Walk heise.de page" do

	include shopSupport

  before :all do
	@browser = Webtest::BrowserFactory.new.newBrowser
	@browser.dumpOnInspection = true # do not save automatically, if call an assertMethod
  end

  it "should pass this test" do

	# a more special way to use the framework
	out = Webtest::Files.autoClose( SZ::NumericPrefixGenerateService.instance.nextFile "txt" )	
	out.puts "Hello Testcase"
	
	# open a page and check content
	@browser.goto WTAC.config.read("base-url")
	@browser.assertHtmlInclude '<a class="channel_titel" title="heise online News" href="/">News</a>'
	@browser.assertHtmlInclude '<meta name="copyright" content="Heise Zeitschriften Verlag" />'
	
	# as an alternative use regexp
	#@browser.assertHtmlMatches /href="\/".*>News<\/a>/
  end

end
