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
    compact_areas
    # Header
    horiz_divider
    printf @io, "|#{@report[0,0]}#{' '*(label_width-@report[0, 0].size)}"
    printf @io, "|#{area_names}#{' '*(graph_width-area_names.size)}|\n"
    horiz_divider
    # rows
    rows
    # Scale
    horiz_divider
    printf @io, "\n" #TODO
  end

  private

  def rows
    (1...@report.row_count).each do |row|
      printf @io, "|#{@report[row, 0]}#{' '*(label_width-@report[row, 0].to_s.size)}|"
      printed = 0
      (1...@report.column_count).each do |column|
        next unless @report[row,column]
        chars = ( @report[row,column] / max_graph ) * (graph_width-1)
        (0...chars).each do
          printed += 1
          printf @io, ANSI::String.new('#').send(AREA_COLORS[column-1])
        end
      end
      printf @io, "#{' '*(graph_width-printed)}|\n"
    end
  end

  # return the biggest sum of all rows
  def max_graph
    max = 0
    (1...@report.row_count).each do |row|
      sum_row = 0
      (1...@report.column_count).each do |column|
        sum_row += @report[row,column] if @report[row,column]
      end
      max = sum_row if sum_row > max
    end
    max
  end

  AREA_COLORS = [:green, :yellow, :blue, :magenta, :cyan, :red]

  # if area_names.size are bigger than graph_width, or if number of areas is
  # greater than AREA_COLORS.size compact areas as needed.
  def compact_areas
    unless area_names.size > graph_width \
      or @report.column_count-1 > AREA_COLORS.size
      return
    end
    raise 'TODO'
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
    names
  end

  # return width of @report[*, 0]
  def label_width
    max_width = 0
    (0...@report.row_count).each do |row|
      row_label_width = @report[row, 0].to_s.size
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