
require '../lib/webtest/configuration'

module ConfigurationProvider 

	def buildSampleConfiguration 
		cfg = Webtest::Configuration.new

		cfg.loadLocal("
---
plugins:
  testcase-1: 1-BAR
  testcase-2: 2-FOO
") 

		cfg.loadGlobal("
---
foo: bar
goto:
  nested_value: nested_value
  nested_array:
   - \"nested one\"
   - \"nested two\"
an_array:
  - one
  - two
  - three
plugins:
  testcase-1: 1-bar
  testcase-2: 2-foo

data:
  defaults:
    shop-server: pegtest1.int.actebis.com
  FINLAND:
    admin-user: admin-u1
    admin-pass: admin-p1
")

		return cfg
	end


end

describe Webtest::Configuration, " save operations" do
	include ConfigurationProvider

	it "reads admin user value" do
		cfg = buildSampleConfiguration
		cfg.read("data:FINLAND:admin-user")
	end

	it "save new values in global configuration" do
		cfg = buildSampleConfiguration
		cfg.saveGlobalValue("main:new_value", "new value")
		value = cfg.read("main:new_value")
		value.should eql "new value"
	end

end

describe Webtest::Configuration, " read operations" do
	include ConfigurationProvider

	it "prefer localConfiguration values" do
		cfg = buildSampleConfiguration
		value = cfg.read("plugins:testcase-1")
		value.should eql "1-BAR"
	end

	it "raise an error if value does not exist" do
		cfg = buildSampleConfiguration
		expect { cfg.read("foo_not_exist") }.to raise_error
	end

	it "reads existing strings from global configuration" do
		cfg = buildSampleConfiguration
		value = cfg.read("goto:nested_value")
		value.should eql "nested_value"
	end

	it "reads existing arrays from global configuration" do
		cfg = buildSampleConfiguration
		value = cfg.read("an_array")
		value[0].should eql "one"
		value[1].should eql "two"
		value[2].should eql "three"
	end


end
