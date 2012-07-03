
require 'singleton'

module SZ

	class IssueDefinition

		attr_accessor :name	

		#
		# :bug, :enhancement, ...
		#
		attr_accessor :type

		def initialize
			@type = :unknown
			@name = 'unknown'
			@detected = nil		
		end
	
		def detected?
			return @detected == nil	? false : @detected
		end
		
		def markDetected
			@detected = true
		end
		
		def expect
			begin
				val = yield
				if val != false
					@detected = true if @detected != false
				else
					@detected = false
				end
			rescue Exception => e
				@detected = false
			end
		end
		
		def to_s
			return @name.to_s + " [" + @type.to_s + ", " + @detected.to_s + "]"
		end
		
	end

	class IssueDefinitionContext
		include Singleton
		
		attr_reader :issues
		
		def initialize
			reset
		end
		
		def reset
			@issues = Array.new
		end
		
		def create(name, type = :bug)
			issue = IssueDefinition.new
			issue.name = name
			issue.type = type
			
			@issues.push issue
			return issue
		end
	end
	
end