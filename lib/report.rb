require 'report/stat'
require 'report/bucket'
require 'report/data'
require 'matrix'

class Report

  def initialize query
    @query = query
    @stat = nil
    @bucket = nil
  end

  def where report
    @stat = Stat.parse(report)
    if 'by' != (arg=report.shift)
      raise "Wrong argument '#{arg}', should be 'by'."
    end
    @bucket = Bucket.parse(report)
    @stat.bucket = @bucket
    matrix
  end

  private

  # Calculate resulting matrix based on @stat and @bucket
  def matrix
    rows = []
    @query.each do |event|
      @stat.add event
    end
    rows.unshift([@bucket.name, *@stat.headers])
    @stat.each do |stat|
      rows << stat
    end
    Data.new(
      matrix: Matrix[*rows],
      type: @bucket.type,
      size: @bucket.size
      )
  end

end
