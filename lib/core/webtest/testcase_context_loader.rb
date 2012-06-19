require 'yaml'

module Webtest

    class TestcaseContextLoader
        
        attr_writer :testcaseHomeDirectory
        
        def loadAvailableContexts
            
            log = WTAC.instance.log
            
            fileName = @testcaseHomeDirectory.to_s + "/spec.yml"
            specYmlFileExists = File.exists?(fileName) 	
            ymlTestcaseContext = nil
            
            log.debug "Check file existance: " + specYmlFileExists.to_s + " for " + fileName
            if specYmlFileExists
                ymlTestcase = YAML.load(File.open(fileName))
				if ymlTestcase != nil && ymlTestcase != false
					ymlTestcaseContext = ymlTestcase['test-contexts']
				end
            end
            
            log.debug "ymlTestcaseContext = " + ymlTestcaseContext.to_s
            return ymlTestcaseContext
        end
        
    end

end