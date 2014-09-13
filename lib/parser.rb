class Parser

  PUBLIC_ATTRS = [
    :io,
    :event_type,
    :max_line_length,
    :multi_line,
    :multi_line_start,
    :multi_line_max,
    ]

  def initialize options = {}
    PUBLIC_ATTRS.each do |attr|
     eval "@#{attr} = options[:#{attr}]"
    end
  end

  def each

  end

end
