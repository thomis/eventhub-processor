require 'spec_helper'

describe HashExtensions do

	before(:each) do
		@h = { "a" => "b", "b" => { "c" => "d" }}
	end
  
  context "get" do

  	context "string" do
		  it "should get value for known key" do
		  	@h.get("a").should == 'b'
		  end

		  it "should get value from nested key" do
		  	@h.get("b.c").should == 'd'
		  end

		  it "should get nil for unkown key" do
		  	@h.get("unknown").should be_nil
		  end
		end

		context "array" do

		  it "should get value for known key" do
		  	@h.get(%w(a)).should == 'b'
		  end

		  it "should get value from nested key" do
		  	@h.get(%w(b c)).should == 'd'
		  end

		  it "should get nil for unkown key" do
		  	@h.get(%w(unknown)).should be_nil
		  end

		end	

	end	

	context "set" do
		context "string" do
			
			it "should set a new value" do
				@h.set("a","new_value").should == "new_value"
			end

			it "should set a nested value" do
				@h.set("b.c","new_value").should == "new_value"
			end

			it "should not overwrite a value" do
				@h.set("b.c","new_value",false).should == "d"
			end

			it "should set nil" do
				@h.set("b.c",nil).should be_nil
			end

		end
		context "array" do
			
			it "should set a new value" do
				@h.set(%w(a),"new_value").should == "new_value"
			end
		
			it "should set a nested value" do
				@h.set(%w(b c),"new_value").should == "new_value"
			end

			it "should not overwrite a value" do
				@h.set(%w(b c),"new_value",false).should == "d"
			end

			it "should set nil" do
				@h.set(%w(b c),nil).should be_nil
			end

		end

	end

	context "all_keys_with_path" do
		it "should get all key paths in an array" do
			@h.all_keys_with_path.should == ['a','b.c'] 
		end

		it "should get an empy array if empty hash was passed" do
			{}.all_keys_with_path.is_a?(Array).should == true		
			{}.all_keys_with_path.size.should == 0
		end

	end


end