class Event

  attr_accessor :raw, :type

  # Receive a hash containing type: Event::Type, raw: raw event text string.
  def initialize options
    @type = options[:type]
    @raw = options[:raw]
  end

  # Extracted time of event.
  def time
#    Implement using:
#    @raw
#    @type.time_prefix # regex
#    @type.time_format # DateTime.strptime
  end

  # Extract fields from event. Field names are returned by #type.field_names
  def [] field_name
#    Implement using:
#    @raw
#    @type.field_names
  end

  private

end
