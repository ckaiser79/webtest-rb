
require 'webtest/include_locator'
require 'webtest/configuration'
require 'webtest/files'
require 'webtest/startup'
require 'webtest/second_logger_decorator'
require 'webtest/testcase_context'
require 'webtest/testcase_context_loader'
require 'webtest/testrunner'
require 'webtest/testrunner_event_listener'


#order is important here
require 'webtest/browser_logging_decorator'
require 'webtest/browser_instance_service'
require 'webtest/logfile_result_printing_service'

require 'webtest/testcase_locator_service'
require 'webtest/rest-client'
require 'webtest/cucumber_test_engine'


module Webtest

	DEFAULT_RUN_LOGFILE = 'run.log'

	def isTrue(booleanString)
		return true if booleanString == true || booleanString =~ (/(true|t|yes|y|1)$/i)
		return false if booleanString == false || booleanString =~ (/(false|f|no|n|0)$/i)
		raise ArgumentError.new("invalid value for Boolean: \"#{booleanString}\"")
	end
	alias :true? :isTrue

end

