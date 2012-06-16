
$LOAD_PATH << '../../lib/core'

require 'fileutils'
require 'wtac'

describe WTAC do

	it "is a singleton" do

		ac1 = WTAC.instance
		ac2 = WTAC.instance
		ac3 = WTAC.instance

		ac1.should equal(ac2)
		ac1.should equal(ac3)

	end
	
	it "logger exists" do
		ac = WTAC.instance
		
		loggerToStdout = Logger.new(STDOUT)		
		ac.log = loggerToStdout
		
        ac.log.should_not be_nil 
        
	end

end
