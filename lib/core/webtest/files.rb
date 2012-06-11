
module Webtest
	module Files
		
		@@registeredAutoClosableFiles = Array.new 
				
		#
		# File.open(filename, File::WRONLY | File::CREAT)
		#
		def self.openWriteCreate(filename)
			return File.open(filename, File::WRONLY | File::CREAT)
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
	end	
end