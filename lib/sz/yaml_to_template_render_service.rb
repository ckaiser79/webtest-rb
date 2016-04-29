require 'erb'
require 'singleton'

module SZ

	class BindingContainer

		def initialize(data)
			@data = data
		end

		def exposeBinding
			binding
		end

	end

	class YamlToTemplateRenderService
		include Singleton

		def renderAsFile(bindingData, templateFile, destinationFile)

			templateAsString = File.read(templateFile)
			erb = ERB.new(templateAsString)

			renderedData = erb.result(bindingData)

			File.open(destinationFile, "w+") do |f|
				f.write(renderedData)
			end
		end

	end

end
