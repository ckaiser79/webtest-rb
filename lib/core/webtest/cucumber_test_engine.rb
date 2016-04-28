require 'cucumber'
require 'pry'

# http://stackoverflow.com/questions/13864670/ruby-cucumber-how-to-execute-cucumber-in-code
module Webtest

  class CucumberTestEngine

    attr_writer :testcaseSpec
    attr_writer :logDir
    attr_writer :stepDefinitionsDir

    def runTest(out, err)

      # Method 1 - hardcoded features
      args = %w(features/first.feature features/second.feature -d --format html)

      # Method 2 - dynamic features
      features = 'features/first.feature features/second.feature'
      args = features.split.concat %w(-d --format html)

      # Run cucumber
      begin
        Cucumber::Cli::Main.new(args).execute!
      rescue SystemExit
        puts "Cucumber calls @kernel.exit(), killing your script unless you rescue"
      end

    end

  end

end