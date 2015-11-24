require 'yaml'
require 'webtest/include_locator'

module Webtest

  class VariableSubstitution

    def initialize(configuration)
      @configuration = configuration
    end

    def evaluate(resultWithVariables)

      result = resultWithVariables
      if resultWithVariables.class.to_s == "String" && containsVariables?(resultWithVariables)

        result = tryEvaluateVariables(resultWithVariables)
        assertNoVariablesLeft(result);
      end

      return result;
    end

    def containsVariables?(value)
      return value["${"] != nil
    end

    def assertNoVariablesLeft(value)
      if value["${"] != nil
        raise "Unknown Variable '" + $1.to_s + "'"
      end
    end

    private

    def tryEvaluateVariables(valueWithVariables)

      result = valueWithVariables

      while result =~ /^(.*)\$\{([a-zA-Z0-9\-_:.]+)\}(.*)$/
        before = $1
        after = $3
        match = $2

        if match[0] == ":"
          match = match[1..-1]
        end
        match = @configuration.read(match)

        result = before + match.to_s + after
      end

      return result
    end
  end

  class Configuration

    def initialize
      @localConfig = Hash.new
      @globalConfig = Hash.new
      @defaultsConfig = Hash.new
    end

    def available?(path)
      result = readOrReturnNil(@localConfig, path)
      if (result == nil)
        result = readOrReturnNil(@globalConfig, path)
      end
      return result != nil
    end

    def read(path)

      result = readOptional(path)

      if (result == nil)
        raise ArgumentError.new("mandatory value is missing: '" + path + "'")
      end

      return result

    end

    alias readMandatory read

    def readOptional(path)
      result = readOrReturnNil(@localConfig, path)

      if (result == nil)
        result = readOrReturnNil(@globalConfig, path)
      end

      if (result == nil)
        result = readOrReturnNil(@defaultsConfig, path)
      end

      varsubst = VariableSubstitution.new(self)
      result = varsubst.evaluate(result)
      return result
    end


    def saveGlobalValue(path, value)

      #ensure included hashes exists
      readOptional path

      hash = @globalConfig
      lastHash = nil
      lastKey = nil

      for item in path.split(":") do

        lastKey = item
        lastHash = hash

        #puts "lastKey=" + lastKey.to_s
        #puts "lastHash=" + lastHash.to_s
        #puts

        hash = hash[lastKey]
        if (hash == nil)
          new_hash = {}
          lastHash[lastKey] = new_hash
          hash = new_hash
        end
      end

      lastHash[lastKey] = value
    end

    def setGlobal(hash)
      @globalConfig = hash
    end

    def loadApplicationDefaults(yamlString)
      @defaultsConfig = doLoadConfiguration(yamlString)
    end

    def loadGlobal(yamlString)
      @globalConfig = doLoadConfiguration(yamlString)
    end

    def loadLocal(yamlString)
      @localConfig = doLoadConfiguration(yamlString)
    end

    private

    def doLoadConfiguration(yamlString)
      if (yamlString == nil)
        return nil
      else
        return YAML.load(yamlString)
      end
    end

    def readOrReturnNil(configuration, path)

      if (configuration == nil)
        return nil
      end

      includeLocator = Webtest::IncludeLocator.new
      parent = configuration

      for item in path.split(":") do
        child=parent[item]

        if includeLocator.includeFile?(child)

          # remove include statement
          parent[item] = nil

          # add new subtree to global configuration
          fileName = includeLocator.includedFileName(child)

          ymlString = File.open(fileName)
          ymlObject = YAML.load(ymlString)

          parent[item] = ymlObject
          child = parent[item]

        end

        if (child == nil)
          return nil
        else
          parent = child
        end
      end

      return parent
    end

  end
end