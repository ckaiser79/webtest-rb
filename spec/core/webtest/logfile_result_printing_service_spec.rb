
require 'webtest'
require 'pry'

describe "logfile_result_printing_service" do

	before :each do
		cfg = Webtest::Configuration.new
			cfg.loadGlobal("
---
main:
  verbose: false
")
		WTAC.instance.config = cfg
		@fileName = 'logfile_result_printing_service.sample.txt'
		@service = Webtest::LogfileResultPrintingService.instance
	end

    it "find failures" do    
		out = @service.allFailures @fileName
		puts out.join("")
		out.size.should eq 3
    end
	
	it "find issues" do
		out = @service.allIssues @fileName
		puts out.join("")
		out.size.should eq 1
    end
	
	it "find succeeds" do	
		out = @service.allSucceeds @fileName
		puts out.join("")
		out.size.should eq 2
    end

end