
require 'sz'
require 'webtest'

describe "Walk heise.de page" do

  before :all do
	@browser = Webtest::BrowserFactory.new.newBrowser
	@browser.dumpOnInspection = false # do not save screenshots automatically
  end

  it "should pass this test" do

    puts "start"
	# a more special way to use the framework
	out = Webtest::Files.autoClose SZ::NumericPrefixGenerateService.instance.nextFile "txt"
	out.puts "Hello Testcase"
	puts "write file"
    
	# open a page and check content
	@browser.goto WTAC.instance.config.read "base-url"
    @browser.dump

    source = @browser.html
    
    source.should include '<a class="channel_titel" title="heise online News" href="/">News</a>'
	source.should include '<meta name="copyright" content="Heise Zeitschriften Verlag" />'
	
  end

end
