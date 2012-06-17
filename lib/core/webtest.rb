
require 'webtest/configuration'
require 'webtest/files'
require 'webtest/startup'
require 'webtest/second_logger_decorator'
require 'webtest/testcase_context'
require 'webtest/testcase_context_loader'
require 'webtest/testrunner'


#order is important here
require 'webtest/browser_logging_decorator'
require 'webtest/browser_factory'

require 'webtest/testcase_locator_service'

module Webtest

	def isTrue(booleanString)
		return true if booleanString == true || booleanString =~ (/(true|t|yes|y|1)$/i)
		return false if booleanString == false || booleanString =~ (/(false|f|no|n|0)$/i)
		raise ArgumentError.new("invalid value for Boolean: \"#{booleanString}\"")
	end

end

