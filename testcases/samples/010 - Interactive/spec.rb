
require 'sz'
require 'webtest'
require 'ripl'

describe "Open an interactive shell" do

  before :all do
	@browser = Webtest::BrowserInstanceService.instance.sharedBrowser
	@browser.dumpOnInspection = true # save screenshots automatically
  end

  it "Supports interactive testing" do
    puts "Call @browser.baseUrl = ... before starting"
    Ripl.start :binding => binding
  end

  def dump(name = nil)
	@browser.dump name
  end
  
  def comment(name)
	dump name
	puts 
	comment = gets.chomp
	WTAC.instance.log.info "comment for " + name + ":" + comment
  end
  
end
