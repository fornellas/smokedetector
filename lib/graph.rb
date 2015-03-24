#require 'io/console'
require 'report/data'
require 'ansi/string'

class Graph

  # Receive Report::Data object.
  def initialize report_data
    @original_report_data = report_data
  end

  # Raised when terminal is too small
  class SmallTerminal < RuntimeError ; end

  # Write graph to given IO object, which must respond to #winsize.
  def fprint io
    @io = io
    get_terminal_attrs
    max_label_width.downto(min_label_width).each do |label_width|
      new_graph(label_width)
#      compact_areas
#      draw_header
#      compact_rows
#      draw_rows
      # Retry if label_width was too big
      if @biggest_label_width < @label_width and @label_width > min_label_width
        next
      end
#      draw_graph_legend
    end
    printf @io, @buffer
  end

  private

  # ----------------------------------------
  # :section: Terminal
  # ----------------------------------------

  # Read terminal attributes and save to @terminal_height, @terminal_width
  def get_terminal_attrs
    @terminal_height, @terminal_width = @io.winsize
    if @terminal_width < min_terminal_width
      raise SmallTerminal.new("Terminal width (#{@terminal_width}) is too small, must be at least #{min_terminal_width}.")
    end
  end

  # ----------------------------------------
  # :section: Drawing functions
  # ----------------------------------------

  # Terminal colors for each graph area
  AREA_COLORS = [:magenta, :blue, :cyan, :green, :yellow, :red]

  # Set variables for new graph with given label width
  def new_graph label_width
    @label_width = label_width
    @report_data = @original_report_data.dup # Work on a copy
    @buffer = ''
    @biggest_label_width = 0
  end

  # Draw headers based on @label_width
  def draw_header
    horiz_divider
    @buffer += "|#{label(@report_data.matrix[0][0])}|"
    # TODO
    horiz_divider
  end

  # Draw horizontal divider
  def horiz_divider
    @buffer += "+#{'-'*@label_width}+#{'-'*graph_width}+\n"
  end

  # Convert str to a String that fit inside @label_width, trimming big strings.
  # Update @biggest_label_width to str.size if it is bigger than @biggest_label_width.
  def label str
    size = str.size
    @biggest_label_width = size if size > @biggest_label_width
    if size > @label_width
      "#{str[0,@label_width-3]}..."
    else
      "#{str}#{' ' * (@label_width - size)}"
    end
  end

  # ----------------------------------------
  # :section: @report_data processing
  # ----------------------------------------

  # Compact @report_data to fit #max_areas.
  def compact_areas
    report_areas = @report_data.matrix[0].size - 1
    return unless report_areas > max_areas
    lines = []
    header = @report_data.matrix[0][(0...max_areas)]
    header << 'others'
    lines << header
    row_count = @report_data.matrix.size
    (1...row_count).each do |row_number|
      row = @report_data.matrix[row_number]
      others = row[max_areas..row.size].inject(:+)
      lines << ( row[0...max_areas] << others )
    end
    @report_data = Report::Data.new(
      matrix: [*lines],
      type: @report_data.type,
      size: @report_data.size,
      )
  end

  # Maximum number or graph areas
  def max_areas
    AREA_COLORS.size
  end

  # ----------------------------------------
  # :section: Table dimensions
  # ----------------------------------------

  # Vertical separators width
  def vert_sep_width ; 3 ; end

  # Maximum label width set to half terminal width
  def max_label_width ; ( @terminal_width - vert_sep_width ) / 2 ; end

  # Minimum width for label column (eg. label equal "L...")
  def min_label_width ; 4 ; end

  # Graph column width, based on current @label_width
  def graph_width ; @terminal_width - @label_width - vert_sep_width ; end

  # Minimum graph column width (eg: "#|#")
  def min_graph_width ; 3 ; end

  # Minimum terminal width
  def min_terminal_width 
    3 + # borders
    min_label_width +
    min_graph_width
  end

end