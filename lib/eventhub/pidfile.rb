class EventHub::Pidfile
  attr_reader :file
  def initialize(file)
    @file = file
  end

  # write the pid to the file specified in the initializer
  def write(pid)
    FileUtils.makedirs(File.dirname(file))
    IO.write(file, pid.to_s)
  end

  # Try to delete file, ignore all errors
  def delete
    begin
      File.delete(file)
    rescue
      # ignore
    end
  end
end