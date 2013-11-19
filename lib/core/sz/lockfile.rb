
module SZ

	class Lockfile
	
		attr_reader :fileName
			
		def initialize(lockFileName)
			@fileName = lockFileName
			@lockDone = false
		end
		
		def lock
		
			if File.exists?(@fileName)				
				raise "lockfile already exists, pid is " + dump
			end
			
			file = File.open(@fileName, "w")
			file.write Process.pid		
			file.close
			
			@lockDone = true
		end
		
		def exists?
			return @lockDone && File.exists?(@fileName)
		end
		
		def unlock	
			if not @lockDone
				raise "Try to raise foreign lockfile " + dump 
			end
			File.delete(@fileName)
			@lockDone = false
		end
		
		private 
		
		def dump
			if File.exists? @fileName
				file = File.open(@fileName, "r")
				content = file.read.to_s
				file.close
			end
			
			return @fileName + ' [' + content + ']'
		end
	end
end