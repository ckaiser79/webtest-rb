require 'singleton'

module Webtest
	class LogfileResultPrintingService
		
		include Singleton

		def allSucceeds(fileName)
			file = open(fileName)
			results = scanFileContent 'suceesful results' , file, /\[SUCCESS\]/, fileName
			return results
		ensure 
			file.close if file != nil 
		end
		
		def allIssues(fileName)
			file = open(fileName)
			results = scanFileContent 'issue warnings' , file, /WARN -- : Detected issue:/, fileName
			return results
		ensure 
			file.close if file != nil 
		end
		
		def allFailures(fileName)
			file = open(fileName)
			results = scanFileContent 'failures' , file, /\[FAIL\]/, fileName
			return results
		ensure 
			file.close if file != nil 
		end
		
		private
		
		def scanFileContent(type, file, pattern, fileName)
			config = WTAC.instance.config
			puts 'Scanning for ' + type + ' in ' + fileName.to_s if config.read('main:verbose')
			
			results = file.grep(pattern)			
			return results
		end
	end
end
