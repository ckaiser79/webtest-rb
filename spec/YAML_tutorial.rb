#!/usr/bin/ruby

require 'yaml'

parsed = begin
  YAML.load(File.open("test.yml"))
rescue ArgumentError => e
  puts "Could not parse YAML: #{e.message}"
end

puts parsed.class
puts parsed['name'].class.to_s + ": " + parsed['name']
