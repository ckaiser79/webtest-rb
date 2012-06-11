#!/usr/bin/env ruby

$LOAD_PATH << '../lib'

require 'logger'
require 'singleton'

$counter = 0

module Webtest


    module Testrun

        class Testrun
       
            attr_reader :context
           
            def initialize
                @context = Context.instance.init "<unknown>"
            end
           
            def run
              @context.namedVariables[:lastResult] = :fail
              puts "run"
            end
               
        end    

        class Context

            include Singleton

            attr_reader :namedVariables
           
            attr_accessor :nextExecutionState
            attr_accessor :lastResult
            attr_accessor :name
           
            attr_reader :logDir
            attr_reader :codeDir
           
            def initialize
                init "<unknown>"
            end

            def log
                return Logger.new(STDOUT) # WTAC.instance.log in real code
            end
           
            def tr(key)
                translate = @namedVariables[:translator]
                raise "No translator available" if translate == nil
                return translate.key key
            end

            def init(name)
                @namedVariables = Hash.new
               
                @name = name
                @lastResult = :not_executed
                @nextExecutionState = :continue
                return self
            end
           
        end

        class BeforeAfterAdvice

            def onBeforeTestrun(testrunContext)
            end
           
            def onAfterTestrun(testrunContext)
                suggestExecutionBreak testrunContext
            end    
           
            protected
           
            def suggestExecutionContinue(testrunContext)
                testrunContext.nextExecutionState = :continue;
            end
           
            def suggestExecutionBreak(testrunContext)
                if(testrunContext.nextExecutionState != :continue)
                    testrunContext.nextExecutionState = :break;
                end
            end
           
        end

        class ArchiveTestcaseCodeAdvice < BeforeAfterAdvice
            def onAfterTestrun(testrunContext)
                puts "copy " + testrunContext.codeDir.to_s + " content to " + testrunContext.logDir.to_s
            end
        end


        class BuildBrowserInstanceAdvice < BeforeAfterAdvice
            def onBeforeTestrun(testrunContext)
                testrunContext.namedVariables[:browser] = "A Browser"
                puts "open a browser " + testrunContext.namedVariables[:browser]
            end
        end

        class MkdirLogDirectoryAdvice < BeforeAfterAdvice
            def onBeforeTestrun(testrunContext)
                puts "create log directory " + testrunContext.logDir.to_s
            end
        end

        class AbortLoopAfterAdvice < BeforeAfterAdvice
           
            def onAfterTestrun(testrunContext)
                $counter = $counter + 1
                if $counter > 3
                    testrunContext.nextExecutionState = :break
                   
                else
                    suggestExecutionBreak testrunContext
                end
            end
        end
       
        class SetOkResultBeforeAdvice < BeforeAfterAdvice
            def onBeforeTestrun(testrunContext)
                testrunContext.lastResult = :ok
            end
        end
       
        class DefaultBeforeAfterAdvicesFactory
           
            def buildBeforeAdvices
                a = Array.new
                a.push Webtest::Testrun::SetOkResultBeforeAdvice.new
                a.push Webtest::Testrun::MkdirLogDirectoryAdvice.new
                return a
            end
           
            def buildAfterAdvices
                a = Array.new
                a.push Webtest::Testrun::AbortLoopAfterAdvice.new
                a.push Webtest::Testrun::ArchiveTestcaseCodeAdvice.new
                return a
            end
           
        end
       
    end
    
    module Tc
    
        class ActebisBeforeAfterAdvicesFactory < Webtest::Testrun::DefaultBeforeAfterAdvicesFactory
           
            alias :superBuildBeforeAdvices :buildBeforeAdvices
           
            def buildBeforeAdvices
                a = superBuildBeforeAdvices
                a.push Webtest::Testrun::BuildBrowserInstanceAdvice.new
                return a
            end
       
        end
       
    end
end


###

# string is mandatory from configuration
factory = eval("Webtest::Tc::ActebisBeforeAfterAdvicesFactory").new # => factory = Webtest::Tc::ActebisBeforeAfterAdvicesFactory.new

beforeAdvices = factory.buildBeforeAdvices
afterAdvices = factory.buildAfterAdvices

testrun = Webtest::Testrun::Testrun.new
state = :continue

while (state == :continue)
   
    puts "Execute " + testrun.context.name
   
    beforeAdvices.each do |advice|
        puts "Beforeadvice " + advice.to_s
        advice.onBeforeTestrun(testrun.context)
    end
    
    testrun.run
    
    afterAdvices.each do |advice|
        puts "Afteradvice  " + advice.to_s
        advice.onAfterTestrun(testrun.context)
    end
    
    testrunContext = testrun.context
    state = testrunContext.nextExecutionState
    puts "EXECUTION = " + testrunContext.nextExecutionState.to_s
    puts "RESULT    = " + testrunContext.lastResult.to_s
    
end

