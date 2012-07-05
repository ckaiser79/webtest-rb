
require 'fileutils'

task :default => :help

task :help do
	puts "rake <rm_logs|rm_vendor|install>"
end

task :lgpl_prepare => [ :rm_vendor_files, :rm_logs ]

task :rm_logs do
	FileUtils.rm_rf('log')
end

task :rm_vendor_files do
	FileUtils.rm_rf('lib/vendor')
	FileUtils.rm_rf('spec/vendor')
	FileUtils.rm_rf('bin-vendor')
end
	
task :install do
	FileUtils.mkdir('lib/vendor')
	FileUtils.mkdir('spec/vendor')
	FileUtils.mkdir('bin-vendor')
end
	
	