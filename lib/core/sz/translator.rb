
require 'wtac'
require 'singleton'

module SZ

	class TranslatorFactory
		
		def self.build(prefix)
			config = WTAC.instance.config
			return Translator.new(prefix, config)
		end	
	end
	
	class Translator
	
		def initialize(prefix, messageSource)
			@prefix = prefix.to_s
			@messageSource = messageSource
		end

		def key(key)
			return @messageSource.read(@prefix + key)
		end
		alias :read :key 
	
	end
	
	class TranslatorHolder
	
		include Singleton
		
		attr_accessor :translator
        attr_accessor :data
		        
        def dt(key)
			return @data.key(key)
		end
        
		def tr(key)
			return @translator.key(key)
		end
	end
end
