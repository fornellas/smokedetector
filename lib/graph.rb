require 'io/console'
require 'ansi/string'

class Graph

  def initialize report
    @report = report
  end

  # print graph to given IO object
  def fprint io
    @io = io
    @terminal_height, @terminal_width = io.winsize
    # compact areas if needed
    compact_areas
    # header
    horiz_divider
    printf @io, "|#{@report[0,0]}|#{area_names}\n"
    horiz_divider
    # TODO rows
    horiz_divider
  end

  private

  AREA_COLORS = [:red, :green, :yellow, :blue, :magenta, :cyan]

  # if area_names.size are bigger than graph_width, compact areas as needed to "others".
  # also compact if number of areas is greater than AREA_COLORS.size
  def compact_areas
    
  end

  def horiz_divider
    printf @io, "+#{'-'*label_width}+#{'-'*graph_width}+\n"
  end

  # return colored names of @report[0,1] up to @report[0, @report.column_count -1]
  def area_names
    names = ANSI::String.new("")
    (1...@report.column_count).each do |column|
      names += ' ' if names.size > 0
      names += ANSI::String.new(@report[0, column]).send(AREA_COLORS[column-1])
    end
    names.to_s
  end

  # return width of @report[*, 0]
  def label_width
    max_width = 0
    (0...@report.row_count).each do |row|
      row_label_width = @report[row, 0].size
      max_width = row_label_width if row_label_width > max_width
    end
    max_width
  end

  # return width of graph area
  def graph_width
    borders = 3
    @terminal_width - ( borders + label_width )
  end
end