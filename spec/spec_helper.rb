require 'rspec'

Dir.glob(File.join(File.join(File.dirname(__FILE__), "..", "lib/core"), "**.rb")).each do |file|
  require file
end
