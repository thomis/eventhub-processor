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
	  	expect(EventHub::Helper.class_to_array(c.class)).to  eq(["event_hub", "plate_store","router"])
	  end

	  it "should be able to deal with a string" do
	  	expect(EventHub::Helper.class_to_array("A::B::C")).to eq(["a", "b", "c"])
	  end

	  it "should give an empty string if you pass nil" do
	  	expect(EventHub::Helper.class_to_array(nil)).to eq([])
	  end

	end

	context "format string" do

		it "should respect minimu max characters value of 5" do
			(-1..5).each do |n|
				expect(format_string("short1", n)).to eq("sh...")
			end
		end

		it "should not cut if string size is same as max characters" do
			expect(format_string("short1", 6)).to eq("short1")
		end

		it "should cut string if string is longer than max characters" do
			expect(format_string("a longer word", 10).size).to eq(10)
			expect(format_string("a longer word", 10)).to eq("a longe...")
		end

	end

end
