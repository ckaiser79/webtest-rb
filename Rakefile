
require 'fileutils'
require 'rake/packagetask'
require 'rdoc/task'

NAME='webtest-rb'
VERSION='0.0-SNAPSHOT'

task :default => :help
task :package => [ :lgpl_prepare, :install ]

task :help do
	puts "rake <rdoc|rm_logs|rm_vendor_files|install|package>"
end

task :lgpl_prepare => [ :rm_vendor_files, :rm_logs ]

task :rm_logs do
	FileUtils.rm_rf('log')
	FileUtils.rm_rf('pckg')
	FileUtils.rm_rf('generated')
end

task :rm_vendor_files do
	FileUtils.rm_rf('vendor')
end
	
task :install do
	FileUtils.mkdir('vendor/bin')
	FileUtils.mkdir('vendor/lib')
	FileUtils.mkdir('vendor/spec')	
end

RDoc::Task.new do |rdoc|
	rdoc.main = 'README.rdoc'
	rdoc.rdoc_dir = 'generated/api-doc'
	rdoc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
	rdoc.options << '--visibility=public'
end
	
Rake::PackageTask.new(NAME, VERSION) do |p|
    p.need_tar = true
    p.package_files.include("lib/**/*")
	p.package_files.include("spec/**/*")
	p.package_files.include("bin/*")
	p.package_files.include("conf/*")
	
	p.package_files.include("Rakefile")
	p.package_files.include("Gemfile")
	p.package_files.include("LICENSE.txt")
	p.package_files.include("README.txt")
	
	p.package_files.include("testcases/samples/**/*")
end
	