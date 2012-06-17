
require 'singleton'

module Webtest

    class TestcaseContext
    
        include Singleton
    
        DEFAULT_CONTEXT_NAME = "unknown-context"
        
        attr_accessor :name
        attr_writer :contextYaml
        
        def initialize
            reset
        end
        
        def reset
            @name = DEFAULT_CONTEXT_NAME
            @contextYaml = nil
        end
    
    end

end