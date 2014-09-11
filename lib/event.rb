class Event

  attr_accessor :raw, :type

  def initialize raw, type
#    @type = type
#    @raw = type
  end

  def time
#    @raw
#    @type.time_prefix # regex
#    @type.time_format # DateTime.strptime
#    @type.time_utc_offset # em segundos
  end

  def field_names
#    @type.fields # regex
  end

  def [] field_name
#    @raw
#    @type.fields
  end

  private

end
