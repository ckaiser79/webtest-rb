require '../lib/file_utils'


$LOGDIR = '../log'

describe FileUtils, "work with directories" do
	it "creates and removes nested directories" do		
		
		FileUtils.removeDirectory($LOGDIR + "/020 TC Sample/variant1")
		File.exists?($LOGDIR + "/020 TC Sample/variant1").should == false
		
		FileUtils.makeDirectory($LOGDIR + "/020 TC Sample/variant1")
		File.exists?($LOGDIR + "/020 TC Sample/variant1").should == true
		
		FileUtils.makeDirectory($LOGDIR + "/020 TC Sample/variant1")
		File.exists?($LOGDIR + "/020 TC Sample/variant1").should == true
		
		FileUtils.removeDirectory($LOGDIR + "/020 TC Sample/variant1")
		File.exists?($LOGDIR + "/020 TC Sample/variant1").should == false
		
		FileUtils.removeDirectory($LOGDIR + "/020 TC Sample/variant1")
		File.exists?($LOGDIR + "/020 TC Sample/variant1").should == false
		
	end
end
