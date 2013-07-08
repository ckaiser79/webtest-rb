
require 'yaml'
require 'webtest'
require 'sz/template_rendering_service'

describe SZ::YamlToTemplateRenderService do

	it "renders a html file" do
		service = SZ::YamlToTemplateRenderService.instance

		yamlData = YAML::load_file('samples/input.yml')
		templateFile = 'samples/logfile.template.html'
		destinationFile = 'samples/logfile.html'

		service.renderAsFile(SZ::BindingContainer.new(yamlData['eventlog']).exposeBinding, templateFile, destinationFile)
	end

end
