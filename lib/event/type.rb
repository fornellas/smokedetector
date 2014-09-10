class Event::Type

  PUBLIC_ATTRS = [:time_prefix, :time_format, :time_utc_offset, :fields]

  attr_accessor(*PUBLIC_ATTRS)

  def initialize options = {}
    PUBLIC_ATTRS.each do |attr|
     eval "@#{attr} = options[:#{attr}]"
    end
  end

end
