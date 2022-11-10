module EventHub
  module Helper
    # converts a class like EventHub::PlateStore::MyClassName to an array ['event_hub','plate_store','my_class_name']
    def class_to_array(class_name)
      class_name.to_s.split("::").map { |m| m.gsub(/[A-Z]/) { |c| "_#{c}" }.gsub(/^_/, "").downcase }
    end

    # replaces CR, LF, CRLF with ";" and cut's string to requied length by adding "..." if string would be longer
    def format_string(message, max_characters = 80)
      max_characters = 5 if max_characters < 5
      m = message.gsub(/\r\n|\n|\r/m, ";")
      return (m[0..max_characters - 4] + "...") if m.size > max_characters
      m
    end

    def now_stamp(now = nil)
      now ||= Time.now
      now.utc.strftime("%Y-%m-%dT%H:%M:%S.#{now.usec}Z")
    end

    def duration(difference)
      negative = difference < 0
      difference = difference.abs

      rest, secs = difference.divmod(60) # self is the time difference t2 - t1
      rest, mins = rest.divmod(60)
      days, hours = rest.divmod(24)
      secs = secs.truncate
      milliseconds = ((difference - difference.truncate) * 1000).round

      result = []
      result << "#{days} days" if days > 1
      result << "#{days} day" if days == 1
      result << "#{hours} hours" if hours > 1
      result << "#{hours} hour" if hours == 1
      result << "#{mins} minutes" if mins > 1
      result << "#{mins} minute" if mins == 1
      result << "#{secs} seconds" if secs > 1
      result << "#{secs} second" if secs == 1
      result << "#{milliseconds} milliseconds" if milliseconds > 1
      result << "#{milliseconds} millisecond" if milliseconds == 1
      (negative ? "-" : "") + result.join(" ")
    end
  end
end
