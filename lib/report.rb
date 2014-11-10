require 'report/stat'
require 'report/bucket'
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
    result = Matrix[*rows]
    eval("
      def result.bucket_type
        :#{@bucket.type}
      end
      ")
    eval("
      def result.bucket_size
        #{@bucket.size}
      end
      ")
    result
  end

end
