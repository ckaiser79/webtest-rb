
require 'yaml'
require 'pry'
require File.join(File.dirname(__FILE__), "/../../spec_helper")

describe SZ::YamlToTemplateRenderService do

	it "renders a html file" do
		service = SZ::YamlToTemplateRenderService.instance

		dir = File.dirname __FILE__
		
		yamlData = YAML::load_file(dir + '/samples/input.yml')
		templateFile = dir + '/samples/logfile.template.html'
		destinationFile = dir + '/samples/logfile.html'

		service.renderAsFile(SZ::BindingContainer.new(yamlData['eventlog']).exposeBinding, templateFile, destinationFile)
	end

	def add name, images
	
		image = Hash.new
		image['name'] = name
		image['image'] = 'gallery/' + name + '.jpg'
		image['source'] = 'gallery/' + name + '.html'
		images.push image
	
		image
	end
	
	it "renders a testcase html file" do
	
		dir = File.dirname __FILE__
		images = Array.new
		d = Hash.new
		d['images'] = images
		d['tc-name'] = "FOO BAR"
		
		add('001', images)
		add('002', images)
		add('003', images)
				
		templateFile = dir + '/samples/testcase.template.html'
		destinationFile = dir + '/samples/testcase.html'

		#binding.pry
		service = SZ::YamlToTemplateRenderService.instance		
		service.renderAsFile(SZ::BindingContainer.new(d).exposeBinding, templateFile, destinationFile)
		
	end
	
end
