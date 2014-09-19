require 'spec_helper'

describe EventHub::Message do

	before(:each) do
		@m = EventHub::Message.new
	end

	context "general" do
		it "should have n required header keys" do
			EventHub::Message::REQUIRED_HEADERS.size.should == 12
		end
	end

	context "initialization" do

		it "should have a valid header (structure and data)" do
			@m.valid?.should be_true
		end

		it "should be invalid if one or more values are nil" do
			EventHub::Message::REQUIRED_HEADERS.each do |key|
				m = @m.dup
				m.header.set(key,nil,true)
				m.valid?.should be_false
			end
		end

		it "should initialize from a json string" do

			# construct a json string
			header = {}
			body   = { "data" => "1"}

			EventHub::Message::REQUIRED_HEADERS.each do |key|
				header.set(key,"1")
			end

			json = {'header' => header, 'body' => body}.to_json
			
			# build message from string
			m = EventHub::Message.from_json(json)


			m.valid?.should be_true

			EventHub::Message::REQUIRED_HEADERS.each do |key|
				header.get(key).should == "1"
			end
				
		end

		it "should initialize to INVALID from an invalid json string" do
			invalid_json_string = "{klasjdkjaskdf"

			m = EventHub::Message.from_json(invalid_json_string)
			m.valid?.should be_true

			m.status_code.should == EventHub::STATUS_INVALID
			m.status_message.should match(/^JSON parse error/)
			m.raw.should == invalid_json_string
		end


	end

	context "copy" do
		it "should copy the message with status success" do
			copied_message = @m.copy

			copied_message.valid?.should be_true
			copied_message.message_id.should_not == @m.message_id
			copied_message.created_at.should_not == @m.created_at
			copied_message.status_code.should    == EventHub::STATUS_SUCCESS

			EventHub::Message::REQUIRED_HEADERS.each do |key|
				next if key =~ /message_id|created_at|status.code/i
				copied_message.header.get(key).should == @m.header.get(key)
			end
		end

		it "should copy the message with status invalid" do
			copied_message = @m.copy(EventHub::STATUS_INVALID)

			copied_message.valid?.should be_true
			copied_message.message_id.should_not == @m.message_id
			copied_message.created_at.should_not == @m.created_at
			copied_message.status_code.should    == EventHub::STATUS_INVALID

			EventHub::Message::REQUIRED_HEADERS.each do |key|
				next if key =~ /message_id|created_at|status.code/i
				copied_message.header.get(key).should == @m.header.get(key)
			end
		end
	end

	context "translate status code" do
		it "should translate status code to meaningful string" do
			EventHub::Message.translate_status_code(EventHub::STATUS_INITIAL).should 				== 'STATUS_INITIAL'
			EventHub::Message.translate_status_code(EventHub::STATUS_SUCCESS).should 				== 'STATUS_SUCCESS'
			EventHub::Message.translate_status_code(EventHub::STATUS_RETRY).should 					== 'STATUS_RETRY'
			EventHub::Message.translate_status_code(EventHub::STATUS_RETRY_PENDING).should 	== 'STATUS_RETRY_PENDING'
			EventHub::Message.translate_status_code(EventHub::STATUS_INVALID).should 				== 'STATUS_INVALID'
			EventHub::Message.translate_status_code(EventHub::STATUS_DEADLETTER).should 		== 'STATUS_DEADLETTER'
		end
	end

end
