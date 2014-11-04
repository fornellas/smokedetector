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
    @buffer = ''
    compact_areas
    # Header
    horiz_divider
    to_buffer "|#{@report[0,0]}#{' '*(label_width-@report[0, 0].size)}"
    names = area_names
    first = names.shift
    to_buffer "|#{first}#{' '*(graph_width-first.size)}|\n"
    names.each do |labels|
      to_buffer "|#{' '*label_width}|#{labels}#{' '*(graph_width-labels.size)}|\n"
    end
    horiz_divider
    # rows
    rows
    # Scale
    horiz_divider
    to_buffer "\n" #TODO
    printf @io, @buffer
    @buffer
  end

  private

  # append giver string to @buffer
  def to_buffer str
    @buffer += str
  end

  # add each row to @buffer
  def rows
    (1...@report.row_count).each do |row|
      to_buffer "|#{@report[row, 0]}#{' '*(label_width-@report[row, 0].to_s.size)}|"
      printed = 0
      (1...@report.column_count).each do |column|
        next unless @report[row,column]
        chars = ( @report[row,column] / max_graph ) * (graph_width-1)
        (0...chars).each do
          printed += 1
          to_buffer ANSI::String.new('#').send(AREA_COLORS[column-1])
        end
      end
      to_buffer "#{' '*(graph_width-printed)}|\n"
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

  # if number of areas is greater than AREA_COLORS.size compact areas as needed.
  def compact_areas
    return unless @report.column_count-1 > AREA_COLORS.size
    raise 'TODO'
  end

  def horiz_divider
    to_buffer "+#{'-'*label_width}+#{'-'*graph_width}+\n"
  end

  # return array of lines with colored names of @report[0,1] up to
  # @report[0, @report.column_count -1]
  def area_names
    lines = []
    names_list = @report.row(0).to_a
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
            second_half = name.slice(split_point)
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
    width = @terminal_width - ( borders + label_width )
    raise 'Terminal width too small.' if width < 2
    width
  end
end