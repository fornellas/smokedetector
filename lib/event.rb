class Event
  attr_accessor :raw, :time
  def initialize(
    raw: nil,
    time: nil,
    field_extraction: nil
    )
    @raw = raw
    @time = time
    @field_extraction = field_extraction
  end
  def fields
    @field_extraction.names
  end
  def [] field
    m = @raw.match(@field_extraction)
    if m
      m[field]
    else
      raise "Unable to match event against #{@field_extraction}."
    end
  end
end
