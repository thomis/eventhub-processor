require 'spec_helper'
include EventHub::Helper

module EventHub
	module PlateStore
		class Router
		end
	end
end


describe EventHub::Helper do

  context "class to string" do

	  it "should convert a class name to a string" do
	  	c = EventHub::PlateStore::Router.new
	  	EventHub::Helper.class_to_array(c.class).should == ["event_hub","plate_store","router"]
	  end

	  it "should be able to deal with a string" do
	  	EventHub::Helper.class_to_array("A::B::C").should == ["a","b","c"]
	  end

	  it "should give an empty string if you pass nil" do
	  	EventHub::Helper.class_to_array(nil).should == []
	  end

	end

	context "format string" do

		it "should respect minimu max characters value of 5" do
			(-1..5).each do |n|
				format_string("short1",n).should == "sh..."
			end
		end

		it "should not cut if string size is same as max characters" do
			format_string("short1",6).should == "short1"
		end

		it "should cut string if string is longer than max characters" do
			format_string("a longer word",10).size.should == 10
			format_string("a longer word",10).should == "a longe..."
		end

	end


	context "host" do

		it "should return a hostname" do
			get_host.should_not be_nil
			get_host.should == Socket.gethostname
			puts get_host
		end
	end

end
