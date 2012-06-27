
require 'yaml'
require 'webtest/include_locator'

module Webtest
    
    class VariableSubstitution
    
        def initialize(configuration)
            @configuration = configuration
        end
        
        def evaluate(resultWithVariables)
            
            result = resultWithVariables
            if resultWithVariables.class.to_s == "String" && containsVariables?(resultWithVariables)
                
                result = tryEvaluateVariables(resultWithVariables)
                assertNoVariablesLeft(result);
            end
            
            return result;
        end
        
        def containsVariables?(value)
            return value["${"] != nil
        end
        
        def assertNoVariablesLeft(value)
            if value["${"] != nil
                raise "Unknown Variable '" + $1.to_s + "'"
            end
        end
        
        private 
        
        def tryEvaluateVariables(valueWithVariables)
        
            result = valueWithVariables

            while result =~ /^(.*)\$\{([a-zA-Z0-9\-_:.]+)\}(.*)$/
                before = $1
                after = $3
                match = $2
                
                if match[0] == ":"
                    match = match[1..-1] 
                end
                match = @configuration.read(match)
                
                result = before + match.to_s + after
            end
        
            return result
        end
    end

	class Configuration

		def available?(path)
			result = readOrReturnNil(@localConfig, path)
			if(result == nil)
				result = readOrReturnNil(@globalConfig, path)
			end
			return result != nil
		end
	
		def read(path)

			result = readOptional(path)

			if(result == nil)
				raise ArgumentError.new("mandatory value is missing: '" + path + "'")
			end

            return result
			
		end
        alias readMandatory read
        
        def readOptional(path)
            result = readOrReturnNil(@localConfig, path)

			if(result == nil)
				result = readOrReturnNil(@globalConfig, path)
			end
            
            varsubst = VariableSubstitution.new(self)
            result = varsubst.evaluate(result)
			return result
        end

        
		def saveGlobalValue(path, value)

			hash = @globalConfig
			lastHash = nil
			lastKey = nil

			for item in path.split(":") do
				lastKey = item
				lastHash = hash

				hash = hash[item]
				if(hash == nil) 
					new_hash = {}
					lastHash[item] = new_hash
					hash = new_hash
				end
			end

			lastHash[lastKey] = value
		end
		
        def setGlobal(hash)
            @globalConfig = hash
        end
        
		def loadGlobal(yamlString)
			if(yamlString == nil) 
				@globalConfig = nil
			else                
				@globalConfig = YAML.load(yamlString)
			end		
			
		end

		def loadLocal(yamlString)
			if(yamlString == nil) 
				@localConfig = nil
			else
				@localConfig = YAML.load(yamlString)
			end		
		end

		private

		def readOrReturnNil(configuration, path)

			if(configuration == nil) 
				return nil
			end

            includeLocator = Webtest::IncludeLocator.new
			parent=configuration
            child = parent
            
			for item in path.split(":") do
				child=parent[item]
                
                if includeLocator.includeFile?(child)
                    
                    # remove include statement
                    parent[item] = nil
                    
                    # add new subtree to global configuration
                    fileName = includeLocator.includedFileName(child)
                    
                    ymlString = File.open(fileName)
                    ymlObject = YAML.load(ymlString)
                    
                    parent[item] = ymlObject
                    child = parent[item]
                end
                
                
				if(child == nil)
					return nil
                else
                    parent = child
				end
			end

			return parent
		end

	end
end