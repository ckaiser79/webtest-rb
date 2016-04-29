require 'singleton'

module Webtest

  class TestcaseContext

    include Singleton

    DEFAULT_CONTEXT_NAME = "unknown-context"

    attr_accessor :name
    attr_writer :contextConfiguration

    def initialize
      reset
    end

    def reset
      @name = DEFAULT_CONTEXT_NAME
      @contextConfiguration = nil
      @cfg = nil
    end

    def to_s
      return @name + ": " + @contextConfiguration.to_s
    end

    def available?(path)
      return false if @contextConfiguration == nil
      loadLazyConfig
      return @cfg.available?(path)
    end

    def read(path)
      return nil if @contextConfiguration == nil
      loadLazyConfig
      return @cfg.read(path)
    end

    def set(var, value)
      loadLazyConfig
      @cfg.saveGlobalValue(var, value)
    end

    private

    def loadLazyConfig

      return if @cfg != nil
      raise "No configurationContext available " + to_s if @contextConfiguration == nil

      @cfg = Webtest::Configuration.new
      @cfg.setGlobal(@contextConfiguration)
    end
  end

end