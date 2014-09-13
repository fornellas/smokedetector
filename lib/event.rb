require 'time'

class Event

  attr_accessor :raw, :type

  # Receive a hash containing type: Event::Type, raw: raw event text string.
  def initialize options
    @type = options[:type]
    @raw = options[:raw]
  end

  # Extracted time of event.
  def time
    if type.time_prefix
      time_str = raw.partition(type.time_prefix)[2]
    else
      time_str = raw
    end
    gmt = DateTime.strptime(time_str, type.time_format).to_time
    gmt - Time.now.gmtoff
  end

  # Extract fields from event. Field names are returned by #type.field_names
  def [] field_name
    if matches = raw.match(type.fields)
      matches[field_name]
    else
      raise "Unable to match event against #{type.fields}."
    end
  end

  private

end
