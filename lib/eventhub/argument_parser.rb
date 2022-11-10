module EventHub
  class ArgumentParser
    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new
      options.environment = "development"
      options.detached = false

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{args[0]}.rb [options]"
        yield(opts, options) if block_given? # allow to add more options

        opts.on("-e", "--environment ENVIRONMENT", "Environment the processor is running") do |environment|
          options.environment = environment
        end

        opts.on("-d", "--detached", "Run processor detached as a daemon") do |v|
          options.detached = v
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end

      opt_parser.parse!(args)
      options
    end
  end
end
