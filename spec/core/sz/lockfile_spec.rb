
$LOAD_PATH << '../../../lib/core'

require 'sz'

describe SZ::Lockfile do

	before :each do
		@lock = SZ::Lockfile.new('./lockfile-spec.lck')
	end
	
	after :each do
		File.delete @lock.fileName if File.exists? @lock.fileName
	end

	it "create lockfiles" do
		@lock.lock
		@lock.exists?.should eql true
	end

	it "unlock lockfiles" do
		@lock.lock
		@lock.exists?.should eql true
		@lock.unlock
		@lock.exists?.should eql false
	end

	it "will not delete other lockfiles" do
		@lock.lock
		expect { @lockfile.lock }.to raise_error
		@lock.unlock
	end
	
	it "abort on existing lockfiles" do
		@lock.lock
		
		lock2 = SZ::Lockfile.new('./lockfile-spec.lck')
		lock2.exists?.should eql false
		expect {lock2.unlock }.to raise_error
		
		@lock.unlock
	end


end