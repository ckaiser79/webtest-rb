
require 'find'
require 'singleton'

module Webtest

	class TestcaseLocatorService
	
		include Singleton
  
		SPEC_RB_FILE = 'spec.rb'
		
		attr_accessor :excludeDirectories
		
		def initialize
			@excludeDirectories = [ ".git", ".svn" ]
		end
		
		def findTestcases(*baseDirectories)
	
			
			result = Array.new
			
			baseDirectories.each do |path| 				
				WTAC.instance.log.info('Using path "' + path.to_s + '"') 
				testcases = findTestcasesSingleDirectory(path)
				result.concat testcases
			end
			
			return result
		end
	
		private 
	
		def findTestcasesSingleDirectory(baseDirectory)
		
			
			result = Array.new
		
			Find.find(baseDirectory) do |path|
			
				if FileTest.directory?(path) && !@excludeDirectories.include?(File.basename(path))
					
					specFileExists = File.exists?(path + '/' + SPEC_RB_FILE)
					
					if(specFileExists)
						result.push path
					end
				else
					Find.prune
				end
				
			end
			
			return result
		end
	end
end