require 'io/console'
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
      compact_areas
      draw_header
      compact_rows
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
    @buffer += "|#{label(matrix[0][0])}"
    names = area_names
    first = names.shift
    @buffer += "|#{first}#{' '*(graph_width-first.size)}|\n"
    names.each do |labels|
      @buffer += "|#{' '*@label_width}|#{labels}#{' '*(graph_width-labels.size)}|\n"
    end
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

  # Return an Array of lines with colored area names, to support #draw_header.
  def area_names
    lines = []
    names_list = matrix[0]
    names_list.shift
    color = 0
    until names_list.empty?
      line_str = ANSI::String.new("")
      while line_str.size < graph_width
        break if names_list.empty?
        extra_space = line_str.text.empty? ? 0 : 1
        if line_str.size + extra_space + names_list.first.size <= graph_width
          colored_name = ANSI::String.new(names_list.shift).send(AREA_COLORS[color])
          color += 1
          line_str += ANSI::String.new("") + ( ' ' * extra_space ) + colored_name
        else
          name = names_list.shift
          split_point = graph_width - (line_str.size + extra_space)
          if split_point == 0
            names_list.unshift name
            break
          else
            first_half = name.slice(0, split_point)
            second_half = name.slice(split_point, name.size)
            colored_name = ANSI::String.new(first_half).send(AREA_COLORS[color])
            line_str += ANSI::String.new("") + ( ' ' * extra_space ) + colored_name
            names_list.unshift(second_half)
          end
        end
      end
      lines << line_str
    end
    lines
  end

  # Maximum number or graph areas
  def max_areas
    AREA_COLORS.size
  end

  # ----------------------------------------
  # :section: @report_data processing
  # ----------------------------------------

  # Compact @report_data to fit #max_areas.
  def compact_areas
    report_areas = matrix[0].size - 1
    return unless report_areas > max_areas
    lines = []
    header = matrix[0][(0...max_areas)]
    header << 'others'
    lines << header
    row_count = matrix.size
    (1...row_count).each do |row_number|
      row = matrix[row_number]
      others = row[max_areas..row.size].inject(:+)
      lines << ( row[0...max_areas] << others )
    end
    @report_data = Report::Data.new(
      matrix: [*lines],
      type: @report_data.type,
      size: @report_data.size,
      )
  end

  # Compact @report_data to fit #max_rows_height if it is bigger.
  def compact_rows
    self.send("compact_rows_#{@report_data.type}")
  end

  # Support for #compact_rows
  def compact_rows_field
    lines = []
    lines << matrix[0]
    (1...max_rows_height).each do |row|
      lines << matrix[row]
    end
    columns = matrix[0].size
    column_values = Array.new(columns - 1)
    column_values.map!{[]}
    (max_rows_height...matrix.size).each do |row|
      (1...columns).each do |column|
        column_values[column - 1] << matrix[row][column]
      end
    end
    lines << ['others'] + column_values.map!{|v| v.inject(:+)}
    @report_data = Report::Data.new(
      matrix: [*lines],
      type: @report_data.type,
      size: @report_data.size,
      )
  end

  # Alias for matrix
  def matrix
    @report_data.matrix
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

  # Assuming @buffer contains only the header, return its height
  def header_height
    @buffer.split("\n").size
  end

  # Height of last graph line, its scale
  def scale_height ; 1 ; end

  # Maximum number of rows
  def max_rows_height
   max = @terminal_height - header_height - scale_height - 1
   max < 2 ? 2 : max
  end

end