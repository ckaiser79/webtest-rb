
module Decorator

	def initialize(decorated)
		@decorated = decorated
	end
  
	def method_missing(method, *args, &block)
		args.empty? ? @decorated.send(method) : @decorated.send(method, *args, &block)
	end
  
end