class Event::Type

  PUBLIC_ATTRS = [:time_prefix, :time_format, :fields]

  attr_accessor(*PUBLIC_ATTRS)

  def initialize options = {}
    PUBLIC_ATTRS.each do |attr|
     eval "@#{attr} = options[:#{attr}]"
    end
    field_names.each do |name|
      raise "Field names can not have '/' in it." if name.match(/\//)
    end
  end

  def field_names
    @fields.names
  end

end
