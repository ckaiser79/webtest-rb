
require 'wtac'

module SZ

	class TranslatorFactory
		def self.build(prefix)
			config = WTAC.instance.config
			return Translator.new(prefix, config)
		end	
	end

	class Translator

		def initialize(prefix, messageSource)
			@prefix = prefix
			@messageSource = messageSource
		end

		def key(key)
			return @messageSource.read(@prefix + key)
		end
	
	end

end
