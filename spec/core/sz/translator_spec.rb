
$LOAD_PATH << '../../../lib/core'

require 'core/sz'
require 'webtest/configuration'


module MessageProvider

	def buildMessages
		cfg = cfg = Webtest::Configuration.new

        cfg.loadGlobal("
---
i18n:
  germany:
    defaults: &i18n-germany-defaults
      login: Default Login
      default_value: default
      blog:
        add: Add
    german:
      <<: *i18n-germany-defaults
      login: Anmelden
      blog:
        show: anzeigen
        edit: bearbeiten
    english:
      <<: *i18n-germany-defaults
      login: Login
      blog:
        show: show
        edit: bearbeiten
        ")
        return cfg
	end

end

describe SZ::Translator, "read translated values" do

	include MessageProvider

	before :each do
		messageSource = buildMessages
		@tr = SZ::Translator.new("i18n:germany:", messageSource)
	end

	it "reads simple messages" do
		@tr.key("german:login").should eql "Anmelden"
		@tr.key("english:login").should eql "Login"
	end

	it "reads nested messages" do
		@tr.key("german:blog:show").should eql "anzeigen"
		@tr.key("english:blog:show").should eql "show"
	end

	it "reads messages in fallback" do
		@tr.key("german:default_value").should eql "default"
        @tr.key("english:default_value").should eql "default"
	end
    
	it "is not able to read nested messages in fallback [BUG]" do
		expect { @tr.key("german:blog:add") }.to raise_error
        expect { @tr.key("english:blog:add") }.to raise_error
	end    

	it "dies if messages does not exist" do
		expect { @tr.key("german:does_not_exist") }.to raise_error
	end
end