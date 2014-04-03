module EventHub

	module Helper

		# converts a base class name, Whatever::MyClassName => my_class_name
		def class_to_string(class_name)
			class_name.to_s.split("::")[-1].gsub(/[A-Z]/) { |c| "_#{c}"}.gsub(/^_/,"").downcase
		end

		def format_raw_string(message,max_characters=80) 
		  max_characters = 5 if max_characters < 5
		  m = message.gsub(/\r\n|\n|\r/m,";")
		  return (m[0..max_characters-3] + "...") if m.size > max_characters
		  return m
	  end

	end	

end