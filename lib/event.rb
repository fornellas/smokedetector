class Event

  attr_accessor :raw, :type

  def initialize options
    @type = options[:type]
    @raw = options[:raw]
  end

  def time
#    @raw
#    @type.time_prefix # regex
#    @type.time_format # DateTime.strptime
#    @type.time_utc_offset # em segundos
  end

  def [] field_name
#    @raw
#    @type.fields
  end

  private

end
