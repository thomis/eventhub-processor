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

    MAX_EXCEPTIONS_FILES = 500

    attr_accessor :folder, :devices

    def initialize(folder=nil)
        @folder_base = folder || Dir.pwd
        @folder_base.chomp!('/')
        @folder            = [@folder_base,'logs'].join('/')
        @folder_exceptions = [@folder_base,'exceptions'].join('/')
        
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

    	FileUtils.makedirs(@folder_exceptions)

      # check max exception log files
      exception_files = Dir.glob(@folder_exceptions + '/*.log')
      if exception_files.size > MAX_EXCEPTIONS_FILES
        exception_files.reverse[MAX_EXCEPTIONS_FILES..-1].each do |file|
          begin
            File.delete(file)
            File.delete(File.dirname(file) + '/' + File.basename(file,".*") + '.msg.raw')
          rescue
          end
        end
      end

      File.open("#{@folder_exceptions}/#{filename}","w") do |output|
        output.write("#{feedback}\n\n")
        output.write("Exception: #{feedback.class.to_s}\n\n")
        output.write("Call Stack:\n")
        feedback.backtrace.each do |line|
          output.write("#{line}\n")
        end
      end

      # save message if provided
      if message
  	    File.open("#{@folder_exceptions}/#{stamp}.msg.raw","wb") do |output|
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



  

