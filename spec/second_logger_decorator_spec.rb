
require 'fileutils'
require 'webtest/second_logger_decorator'
require 'logger'

describe Webtest::SecondLoggerDecorator do

	it "can work without local logger" do

		log = Logger.new(STDOUT)
		
		decoratedLog =  Webtest::SecondLoggerDecorator.new(log);
			
		decoratedLog.info "foo"
		decoratedLog.error "bar"
		decoratedLog.debug "xxx"

	end
	
	it "can work with local logger" do

		log = Logger.new(STDOUT)
		log.level = Logger::INFO
		
		logfile = File.open('../log/decorated.log', File::WRONLY | File::CREAT)
		fileLogger = Logger.new(logfile)
		fileLogger.level = Logger::DEBUG
		
		decoratedLog =  Webtest::SecondLoggerDecorator.new(log);
		decoratedLog.localLogger = fileLogger
	
		decoratedLog.info("foo")
		decoratedLog.error("bar")
		decoratedLog.debug("xxx")

	end

end
