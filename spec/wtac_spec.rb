
require 'fileutils'
require '../lib/wtac'

describe WTAC do

	it "is a singleton" do

		ac1 = WTAC.instance
		ac2 = WTAC.instance
		ac3 = WTAC.instance

		ac1.should equal(ac2)
		ac1.should equal(ac3)

	end
	
	it "can exchange log instance" do
		ac = WTAC.instance
		
		loggerToStdout = Logger.new(STDOUT)		
		ac.log = loggerToStdout
		
		loggerToFile = Logger.new(File.open('out.log', File::WRONLY | File::CREAT))
		
		WTAC.addLocalLogger(loggerToFile)
		WTAC.log.info("to file")
		
		WTAC.removeLocalLogger()		
		WTAC.log.info("to stdout")
		
	end

end
