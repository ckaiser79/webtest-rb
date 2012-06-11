
require 'yaml'

module Webtest
	class Configuration

		def available?(path)
			result = readOrReturnNil(@localConfig, path)
			if(result == nil)
				result = readOrReturnNil(@globalConfig, path)
			end
			return result != nil
		end
	
		def read(path)

			result = readOrReturnNil(@localConfig, path)

			if(result == nil)
				result = readOrReturnNil(@globalConfig, path)
			end

			if(result == nil)
				raise ArgumentError.new("mandatory value is missing: '" + path + "'")
			end

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

			result=configuration

			for item in path.split(":") do
				result=result[item]
				if(result == nil)
					return nil
				end
			end

			return result
		end
	end
end