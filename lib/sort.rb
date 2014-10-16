require 'parsing'

class Sort

  extend Parsing

  def initialize matrix
    @matrix = matrix
  end

  def by args
    @args = args
    return @matrix if @args.empty?
    column = @args.shift
    if match = column.match(/^-(?<column>[^-].*+)/)
      reverse = true
      column = match[:column]
    else
      reverse = false
    end
    header = @matrix.shift
    @matrix.sort! do |a, b|
      index = header.index(column)
      raise "No such column '#{column}'." if index.nil?
      obj_a, obj_b = a[index], b[index]
      if reverse
        obj_b <=> obj_a
      else
        obj_a <=> obj_b
      end
    end
    @matrix.unshift header
    @matrix
  end

end