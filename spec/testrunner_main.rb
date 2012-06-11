#!/usr/bin/env ruby
$LOAD_PATH << '../lib'

require 'logger'
require 'fileutils'

require 'webtest/second_logger_decorator'
require 'wtac'
require 'webtest/configuration'
require 'webtest/testrunner'

$LOGDIR = '../log'
$TCDIR = '../spec'

FileUtils::rm_rf($LOGDIR)
raise "LOGDIR exists" if File.exists?($LOGDIR)

# configure minimal environment
log = Logger.new(STDOUT)
config = Webtest::Configuration.new
config.loadGlobal(File.open('../conf/webtest.yml'))

@ac = WTAC.instance
@ac.config = config

decoratedLog = Webtest::SecondLoggerDecorator.new(log)
@ac.log = decoratedLog

# create a runner and execute 2 testcases after each other
@runner = Webtest::Testrunner.new
@runner.testEngine = Webtest::RspecTestEngine.new

# execute a testcase sucessfully
@runner.testcaseDir = $TCDIR + '/valid_testcase'
@runner.logDir = $LOGDIR + '/valid_testcase'
@runner.run

@runner.testcaseDir = $TCDIR + '/valid_testcase'
@runner.logDir = $LOGDIR + '/valid_testcase'
@runner.run

# does not abort if testcase throws exception
@runner.testcaseDir = $TCDIR + '/tc_valid_throws_exception'
@runner.logDir = $LOGDIR + '/tc_valid_throws_exception'
@runner.run

raise "LOGDIR OUT exists" unless File.exists?($LOGDIR + '/tc_valid_throws_exception')
raise "LOGDIR OUT exists" unless File.exists?($LOGDIR + '/valid_testcase')
