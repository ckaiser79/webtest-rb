
require 'yaml'

YAML_DATA = '
---
test-contexts:
  one:
    value1: O-V1  
    value2: O-V2  
  two:
    value1: T-V1  
    value2: T-V2  
'

OBJ = YAML.load(YAML_DATA)
contexts = OBJ['test-contexts']

contexts.each do |key,value|
    puts key + ": " + value.to_s
end
