require 'logger'

# format adaptation
class Logger
  class Formatter
    def call(severity, time, progname, msg)
      time_in_string = "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{"%04d" % (time.usec/100)}"
      [time_in_string,Process.pid,severity,msg].join("\t") + "\n"
    end
  end
  
end


module EventHub

  class MultiLogger
    def initialize(*targets)
        @targets = targets
    end

    def save_detailed_error(feedback,message=nil)
    	time = Time.now
      stamp = "#{time.strftime("%Y%m%d_%H%M%S")}_#{"%03d" % (time.usec/1000)}"
      filename = "#{stamp}.log"

    	FileUtils.makedirs("exceptions")

      File.open("exceptions/#{filename}","w") do |output|
        output.write("#{feedback}\n\n")
        output.write("Exception: #{feedback.class.to_s}\n\n")
        output.write("Call Stack:\n")
        feedback.backtrace.each do |line|
          output.write("#{line}\n")
        end
      end

      # save message if provided
      if message
  	    File.open("exceptions/#{stamp}.msg.raw","wb") do |output|
  	    	output.write(message)
  	    end
    	end	

      return stamp
    end

    %w(log debug info warn error).each do |m|
      define_method(m) do |*args|
          @targets.map { |t| t.send(m, *args) }
      end
    end

  end

end



  

