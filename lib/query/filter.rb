class Query
  class Filter
    def initialize *filters
      @filters = filters
      zero_filters
      until filters.empty?
        case @filters.first
        when 'from'
          @from_time = parse_time( fetch_args(1).first )
        when 'to'
          @to_time = parse_time( fetch_args(1).first )
        when 'field'
          args = fetch_args(3)
          name = args[0]
          cmd = args[1]
          arg = args[2]
          case cmd
          when 'matches'
            @field_matches << {
              name: name,
              regexp: Regexp.new( arg ),
             }
          else
            raise "Unknown argument '#{cmd}' to 'field'."
          end
        else
          return filters
        end
      end
    end

    def match? event
      # from
      return false if @from_time and event.time < @from_time
      # to
      return false if @to_time and event.time > @to_time
      # field match
      @field_matches.each do |field_match|
        regexp = field_match[:regexp]
        field_name = field_match[:name]
        value = event[field_name]
        return false unless regexp.match value
      end
      true
    end

    private

    def zero_filters
      @from_time = nil
      @to_time = nil
      @field_matches = []
    end

    # Return an array of 'count' arguments from @filters, starting at 1.
    def fetch_args count
      cli = @filters.shift(1+count)
      command = cli.first
      args = cli.drop(1)
      raise "Too few arguments to '#{command}'." if args.size != count
      args
    end

    # Parse time from given string
    def parse_time str
      Time.parse str
    end
  end
end
