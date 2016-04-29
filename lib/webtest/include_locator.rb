

module Webtest

    class IncludeLocator
        def includedFileName(string)
             string =~ /\$\(include:(.+)\)/
             return $1
            
        end
        
        def includeFile?(string)
            if(string =~ /^\$\(include:(.+)/)                
                return true
            else
                return false
            end
        end
    end
    
end