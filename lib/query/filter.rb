class Query
  class Filter

    # Parse filters and return an array of Filter objects, consuming only known
    # arguments from query array.
    def self.parse query
      @query = query
      @filters = []
      until @query.empty?
        filter = nil
        if @query.first == 'not'
          raise "Missing arguments after 'not'." if @query.size < 2
          @query.shift
          filter = get_filter(true)
        else
          filter = get_filter(false)
        end
        if filter
          @filters << filter
        else
          break
        end
      end
      return @filters
    end

    private

    # Return Filter after parsing @query
    def self.get_filter inverse
      until @query.empty?
        case @query.first
        when 'from'
          from_time = parse_time( fetch_args(1).first )
          return Filter.new(inverse: inverse, from_time: from_time)
        when 'to'
          to_time = parse_time( fetch_args(1).first )
          return Filter.new(inverse: inverse, to_time: to_time)
        else
          return nil
        end
      end
    end

    # Return an array of 'count' arguments from @filters, starting at 1.
    def self.fetch_args count
      cli = @query.shift(1+count)
      command = cli.first
      args = cli.drop(1)
      raise "Too few arguments to '#{command}'." if args.size != count
      args
    end

    # Parse time from given string
    def self.parse_time str
      Time.parse str
    end

    public

    def initialize filter
      @filter = filter
    end

    # True if filter is inverse (not).
    def inverse?
      @filter[:inverse]
    end

    # True if filter match event
    def match? event
      # from
      return false if @filter[:from_time] and event.time < @filter[:from_time]
      # to
      return false if @filter[:to_time] and event.time > @filter[:to_time]
      true
    end

  end
end
