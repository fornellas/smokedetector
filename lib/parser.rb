require 'pp'
class Parser

  PUBLIC_ATTRS = [
    :io,
    :event_type,
    :max_line_length,
    :multi_line,
    :multi_line_start,
    :multi_line_max,
    ]

  attr_accessor(*PUBLIC_ATTRS)

  def initialize options = {}
    PUBLIC_ATTRS.each do |attr|
     eval "@#{attr} = options[:#{attr}]"
    end
  end

  def each &block
    last_line = false
    parse_multi_line_start
    io.each_line(max_line_length) do |line|
      raise "Line longer than #{max_line_length}" if last_line
      if line.length == max_line_length and line[-1, 1] != "\n"
        last_line = true
      end

      if multi_line
        parse_multi_line line, &block
      else
        parse_single_line line, &block
      end
    end
  end

  private

  def parse_single_line line
    yield Event.new(
      raw: line,
      type: event_type,
      )
  end

  def parse_multi_line_start
    @events = false
    @raw = ""
    @merge = false
    @lines = 0
  end

  def parse_multi_line line
    @raw += line
    @lines += 1
    if @lines > multi_line_max
      raise "Event has more than #{multi_line_max} lines."
    end
    if line.match multi_line_start
      @events = true
      if @merge
        yield Event.new(
          raw: @raw,
          type: event_type,
          )
      else
        @merge = false
        @raw = ""
      end
    else
      raise "Invalid data before first event: '#{line}'." unless @events
    end
  end

end
