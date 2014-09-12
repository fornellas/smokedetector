class Event::Type

  PUBLIC_ATTRS = [:time_prefix, :time_format, :fields]

  attr_accessor(*PUBLIC_ATTRS)

  def initialize options = {}
    PUBLIC_ATTRS.each do |attr|
     eval "@#{attr} = options[:#{attr}]"
    end
  end

  def field_names
    @fields.names
  end

end
