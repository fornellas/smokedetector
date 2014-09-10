require 'time'

class Extractor
  # io:: IO object to read events from.
  # truncate:: Maximum length of a single line. Bigger lines are truncated to this value.
  # time_prefix:: If regex given, time extraction with +strptime+ will occour after a match of this regexp.
  # strptime:: Time extraction will follow this pattern. See +strptime(3)+.
  # multi_line:: If true, combine events, according to +new_event+.
  # new_event:: Regexp that if found at a line, indicates the start of a new event. Used only with +multi_line+.
  # field_extraction:: Regexp with named captures applied to whole event string, to extract known fields.
  def initialize(
    io: STDIN,
    truncate: 10000,
    time_prefix: nil,
    strptime: nil,
    multi_line: false,
    new_event: nil,
    field_extraction: nil
    )
    @io = io
    @truncate = truncate
    @time_prefix = time_prefix
    @strptime = strptime
    @multi_line = multi_line
    @new_event = new_event
    @field_extraction = field_extraction
  end
  # Executes given block for each parsed event.
  def each
    @io.each_line(@truncate) do |line|
      if @multi_line
        raise 'TODO'
      else
        event = parse_single_line line
      end
      yield event
    end
  end
  private
  def parse_time line
    if @time_prefix
      time_str = line.partition(@time_prefix)[2]
    else
      time_str = line
    end
    DateTime.strptime(time_str, @strptime).to_time
  end
  def parse_single_line line
    raw = line
    time = parse_time line
    Event.new(
      raw: line,
      time: parse_time(line),
      field_extraction: @field_extraction
      )
  end
end
