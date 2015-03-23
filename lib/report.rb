require 'report/stat'
require 'report/bucket'
require 'report/data'

class Report

  def initialize query
    @query = query
    @stat = nil
    @bucket = nil
  end

  def where stat_by_bucket
    @stat = Stat.parse(stat_by_bucket)
    if 'by' != (arg=stat_by_bucket.shift)
      raise "Wrong argument '#{arg}', should be 'by'."
    end
    @bucket = Bucket.parse(stat_by_bucket)
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
      matrix: [*rows],
      type: @bucket.type,
      size: @bucket.size
      )
  end

end
