
require 'singleton'

module Webtest

    class TestcaseContext
    
        include Singleton
    
        DEFAULT_CONTEXT_NAME = "unknown-context"
        
        attr_accessor :name
        attr_writer :contextConfiguration
        
        def initialize
            reset
        end
        
        def reset
            @name = DEFAULT_CONTEXT_NAME
            @contextConfiguration = nil
        end
        
        def to_s
            return @name + ": " + @contextConfiguration.to_s
        end
        
        def key(path)
            
        end
    
    end

end