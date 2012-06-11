
require 'singleton'
require 'webtest'

class WTAC

	include Singleton

	attr_accessor :config
	attr_accessor :log

	def close 
		@log.close
	end

end
