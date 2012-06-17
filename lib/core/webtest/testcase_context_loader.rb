require 'yaml'

module Webtest

    class TestcaseContextLoader
        
        attr_writer :testcaseHomeDirectory
        
        def loadAvailableContexts
            
            specYmlFileExists = File.exists?(@testcaseHomeDirectory + "/spec.yml") 	
            ymlTestcaseContext = nil
            
            if specYmlFileExists
                ymlTestcase = YAML.load(@testcaseHomeDirectory + "/spec.yml")
                ymlTestcaseContext = ymlTestcase['test-contexts']
            end
            
            WTAC.instance.log.info "ymlTestcaseContext = " + ymlTestcaseContext.to_s
            return ymlTestcaseContext
        end
        
    end

end