
require 'singleton'

module SZ

	class NumericPrefixGenerateService
	
		include Singleton
		
		#
		# prepend before nextFile result
		#
		attr_writer :directoryPrefix
		attr_reader :lastString
		
		def initialize
			@counter = 0
			@directoryPrefix = ''
			@lastString = ''
		end
	
		def nextString(suffix = nil)
		
			if(suffix == nil)
				suffix = (0...6).map{65.+(rand(25)).chr}.join
			end
		
			numericString = "%04d" % @counter
			@counter = @counter + 1
			
			@lastString = numericString + "-" + suffix
			
			return @lastString
		end
		
		def nextFile(ext = nil, suffix = nil)
			name = nextFilename(ext, suffix)
			return File.open(name, File::WRONLY | File::CREAT)
		end
		
		def nextFilename(ext = nil, suffix = nil)
		
			randomString = nextString(suffix)			
			extension = buildExtension(ext)
			directory = buildDirectoryPrefix()
			
			return directory + randomString + extension
		end		
		
		def reset(to = 0)
			@counter = to
		end
		
		def lastFilename(ext = nil)
		
			extension = buildExtension(ext)
			directory = buildDirectoryPrefix()
			
			return directory + @lastString + extension
		end
		
		private 
		
		def buildDirectoryPrefix
			directory = ''
			directory = @directoryPrefix if @directoryPrefix != nil && @directoryPrefix.length > 0
			
			if(directory.length > 0 && !(directory =~ /\/$/))
				directory = directory + '/'
			end
			
			return directory
		end
		
		def buildExtension(ext)
			extension = ''
			extension = "." + ext.to_s unless ext == nil
			return extension
		end
	
	end

end