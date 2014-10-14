class Report
  def initialize query
    @query = query
  end

  def where report
    @report = report
    until @report.empty?
      case @report.first
      when 'average'
        return average( fetch_args(1).first )
      else
        raise "Unknow report command '#{@report.first}'"
      end
    end
  end

  private

  # Return an array of 'count' arguments from @report, starting at 1.
  def fetch_args count
    cli = @report.shift(1+count)
    command = cli.first
    args = cli.drop(1)
    raise "Too few arguments to '#{command}'." if args.size != count
    args
  end

  def average field
    count, sum = 0.0, 0.0
    @query.each do |event|
      count += 1
      sum += Float(event[field])
    end
    if count > 0
      [field => sum / count]
    else
      []
    end
  end
end
