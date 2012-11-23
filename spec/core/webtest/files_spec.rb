
require 'webtest/files'
require 'fileutils'

require 'logger'
require 'pry'

describe "logfiles writing" do

    it "flushes logfile" do
        
        logfile = File.open('c:/temp/run.log', File::WRONLY | File::CREAT)
        
        log = Logger.new(logfile)
        log.info "FOOBAR"        
        
        binding.pry
        
        Webtest::Files.close logfile
    end

end