require 'ostruct'



module SZ
	
	class HashDecorator

		def initialize(hash, dropRootKey = false)
			@hash = transformHash(hash, dropRootKey)
		end

		def method_missing(name)
		
			result = nil
			
			if @hash.key? name
				result = @hash[name] 
			else		
				@hash.each do |k,v| 
					if k.to_s.to_sym == name 
						result = v 
					end
				end
			end
			
			if result.is_a? Hash
				return HashDecorator.new(result)
			else
				return result
			end
			
		end
				
		private 
		
		def transformHash(hash, dropRootKey)
			response = nil
			if(dropRootKey)
				# drop root element
				rootKey = ''
				hash.each do |key,value|
					rootKey = key
				end
				response = hash[rootKey]
			else
				response = hash
			end
			return response		
		end
		
	end

end