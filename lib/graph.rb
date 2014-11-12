require 'io/console'
require 'ansi/string'
require 'report/data'

class Graph

  def initialize report_data
    @report_data = report_data
  end

  # print graph to given IO object
  def fprint io
    @io = io
    @terminal_height, @terminal_width = io.winsize
    @buffer = ''
    compact_columns
    horiz_divider
    headers
    horiz_divider
    if matrix.row_count > 2
      if @report_data.type == :string
        compact_rows
      else
        rescale_rows
      end
      rows
      horiz_divider
      scale
    end
    printf @io, @buffer.gsub(/%/, '%%')
    @buffer
  end

  private

  ##
  ## Helper
  ##

  def matrix
    @report_data.matrix
  end

  ##
  ## Columns
  ##

  # if number of columns is greater than max_columns compact areas as needed.
  def compact_columns
    return unless matrix.column_count-1 > max_columns
    lines = []
    header = matrix.row(0).to_a[(0...max_columns)]
    header << 'others'
    lines << header
    (1...matrix.row_count).each do |row_number|
      row = matrix.row(row_number).to_a
      others = row[max_columns..row.size].inject(:+)
      lines << ( row[0...max_columns] << others )
    end
    @report_data = Report::Data.new(
      matrix: Matrix[*lines],
      type: @report_data.type,
      size: @report_data.size,
      )
  end

  def max_columns
    AREA_COLORS.size
  end

  ##
  ## Headers
  ##

  # add headers to @buffer
  def headers
    to_buffer "|#{matrix[0,0]}#{' '*(label_width-matrix[0, 0].size)}"
    names = area_names
    first = names.shift
    to_buffer "|#{first}#{' '*(graph_width-first.size)}|\n"
    names.each do |labels|
      to_buffer "|#{' '*label_width}|#{labels}#{' '*(graph_width-labels.size)}|\n"
    end
  end

  # return array of lines with colored names of matrix[0,1] up to
  # matrix[0, matrix.column_count -1]
  def area_names
    lines = []
    names_list = matrix.row(0).to_a
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

  ##
  ## rows
  ##

  # matrix.@report_data.type == :string

  # if number of rows is bigger than terminal height, compact as needed
  def compact_rows
    return unless matrix.row_count-1 > available_rows
    lines = []
    header = matrix.row(0).to_a
    lines << header
    (1...available_rows).each do |row_number|
      lines << matrix.row(row_number)
    end
    zero_array = Array.new(matrix.column_count-1, 0)
    sum = Vector[*zero_array]
    (available_rows...matrix.row_count).each do |row_number|
      array = matrix.row(row_number).to_a
      array.shift
      vector = Vector[*array]
      sum += vector
    end
    lines << ['others', *sum.to_a]
    @report_data = Report::Data.new(
      matrix: Matrix[*lines],
      type: @report_data.type,
      size: @report_data.size,
      )
  end

  # matrix.@report_data.type == :continuous

  # rescale rows to fill #available_rows
  def rescale_rows
    lines = []
    header = matrix.row(0).to_a
    lines << header
    min = matrix[1,0]
    max = matrix[matrix.row_count-1, 0] + @report_data.size
    bucket_size = (max-min)/available_rows
    # compute sum for each bucket
    sums = {}
    (min...max).step(bucket_size) do |bucket|
      zero_array = Array.new(matrix.column_count-1, 0)
      sums[bucket] = Vector[*zero_array]
    end
    (1...matrix.row_count).each do |row_number|
      row_bucket = matrix.row(row_number)[0]
      bucket = nil
      (min...max).step(bucket_size) do |candidate_bucket|
        if row_bucket >= candidate_bucket && row_bucket < candidate_bucket + bucket_size
          bucket = candidate_bucket
          break
        end
      end
      row_data_array = matrix.row(row_number).to_a
      row_data_array.shift
      sums[bucket] += Vector[*row_data_array]
    end
    # update array
    sums.keys.sort.each do |bucket|
      lines << [bucket, *sums[bucket]]
    end
    @report_data = Report::Data.new(
      matrix: Matrix[*lines],
      type: @report_data.type,
      size: @report_data.size,
      )
  end

  # return number of rows available to be printed depending on headers already
  # present at @buffer, @terminal_height and scale at bottom
  def available_rows
    headers_size = @buffer.split("\n").size
    rows = @terminal_height - headers_size - 2
    raise "Terminal too small" if rows < 1
    rows
  end

  # add each row to @buffer
  def rows
    (1...matrix.row_count).each do |row|
      to_buffer "|#{matrix[row, 0]}#{' '*(label_width-matrix[row, 0].to_s.size)}|"
      printed = 0
      (1...matrix.column_count).each do |column|
        next unless matrix[row,column]
        chars = ( matrix[row,column].to_f / max_graph ) * (graph_width-1)
        (0...chars.to_i).each do
          printed += 1
          to_buffer ANSI::String.new('#').send(AREA_COLORS[column-1])
        end
        if chars-chars.floor >= 0.5
          printed += 1
          to_buffer ANSI::String.new('#').send(AREA_COLORS[column-1])
        end
      end
      to_buffer "#{' '*(graph_width-printed)}" if graph_width-printed > 0
      to_buffer"|\n"
    end
  end

  # return the biggest sum of all rows
  def max_graph
    max = 0
    (1...matrix.row_count).each do |row|
      sum_row = 0
      (1...matrix.column_count).each do |column|
        sum_row += matrix[row,column] if matrix[row,column]
      end
      max = sum_row if sum_row > max
    end
    max
  end

  ##
  ## Scale
  ##

  def scale

  end

  ##
  ## Support
  ##

  AREA_COLORS = [:magenta, :blue, :cyan, :green, :yellow, :red]


  # add divider to @buffer
  def horiz_divider
    to_buffer "+#{'-'*label_width}+#{'-'*graph_width}+\n"
  end

  # append giver string to @buffer
  def to_buffer str
    @buffer += str
  end

  # return width of matrix[*, 0]
  def label_width
    max_width = 0
    (0...matrix.row_count).each do |row|
      row_label_width = matrix[row, 0].to_s.size
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