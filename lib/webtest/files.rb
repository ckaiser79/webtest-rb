
module Webtest
	module Files
		
		@@registeredAutoClosableFiles = Array.new 
        @@registeredAutoFlushableFiles = Array.new 
				
		#
		# File.open(filename, File::WRONLY | File::CREAT)
		#
		def self.openWriteCreate(filename)
			file = File.open(filename, File::WRONLY | File::CREAT)
            return file
		end

		def self.close(file)
			return if(file == nil)
			file.close unless file.closed?
		end
		
		def self.autoClose(file)			
			@@registeredAutoClosableFiles.push file
			return file
		end
		
		def self.closeAll()			
			@@registeredAutoClosableFiles.each do |file|
				close(file)
			end
		end
		
        def self.flush(file)
			return if(file == nil)
			file.flush unless file.closed?
		end
                
        def self.autoFlush(file)			
			@@registeredAutoFlushableFiles.push file
			return file
		end

		def self.flushAll()			
			@@registeredAutoFlushableFiles.each do |file|
				flush(file)
			end
		end

	end	
end