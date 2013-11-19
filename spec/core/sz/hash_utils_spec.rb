
$LOAD_PATH << '../../../lib/core'

require 'sz/hash_utils'

describe SZ::HashDecorator do

	before :each do
		@hash = { 
			'response' => { 
				'code' => 4, 
				'message' => 'foo', 
				'an_array' => [ 'one','two','three'], 
				'nested' => { 
					'foo' => 'bar', 
					'bar' => 'foo' 
				} 
			}
		}
	end

	it "convert 1 : 1" do
		r = SZ::HashDecorator.new @hash
		
		r.response.code.should eq 4
		r.response.message.should eq 'foo'
		
		r.response.nested.foo.should eq 'bar'
		r.response.nested.bar.should eq 'foo'
		
		r.response.an_array[0].should eq 'one'
	end

	it "convert and remove root key" do
		r = SZ::HashDecorator.new @hash, true
		
		r.code.should eq 4
		r.message.should eq 'foo'
		
		r.nested.foo.should eq 'bar'
		r.nested.bar.should eq 'foo'
		
		r.an_array[0].should eq 'one'
	end
end