
require 'fileutils'
require 'rake/packagetask'

NAME='webtest-rb'
VERSION='0.0-SNAPSHOT'

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
	
Rake::PackageTask.new(NAME, VERSION) do |p|
    p.need_tar = true
    p.package_files.include("lib/**/*.rb")
	p.package_files.include("spec/**/*")
	p.package_files.include("bin/*")
	p.package_files.include("Rakefile")
	p.package_files.include("LICENSE.txt")
	p.package_files.include("README.txt")
	p.package_files.include("conf/*")
	p.package_files.include("testcases/**/*")
end
	