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

    attr_accessor :folder, :devices

    def initialize(folder=nil)
        @folder = folder || (Dir.pwd + '/log')
        @devices = []

        FileUtils.makedirs(@folder)
    end

    def add_device(device)
      @devices << device
    end

    def save_detailed_error(feedback,message=nil)
    	time = Time.now
      stamp = "#{time.strftime("%Y%m%d_%H%M%S")}_#{"%03d" % (time.usec/1000)}"
      filename = "#{stamp}.log"

    	FileUtils.makedirs("#{folder}/exceptions")

      File.open("#{@folder}/exceptions/#{filename}","w") do |output|
        output.write("#{feedback}\n\n")
        output.write("Exception: #{feedback.class.to_s}\n\n")
        output.write("Call Stack:\n")
        feedback.backtrace.each do |line|
          output.write("#{line}\n")
        end
      end

      # save message if provided
      if message
  	    File.open("#{@folder}/exceptions/#{stamp}.msg.raw","wb") do |output|
  	    	output.write(message)
  	    end
    	end	

      return stamp
    end

    %w(log debug info warn error).each do |m|
      define_method(m) do |*args|
          @devices.map { |d| d.send(m, *args) }
      end
    end

  end

end



  

