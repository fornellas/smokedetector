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
          return Filter.new(inverse: inverse, command: :from, args: from_time)
        when 'to'
          to_time = parse_time( fetch_args(1).first )
          return Filter.new(inverse: inverse, command: :to, args: to_time)
        when 'field'
          name, command, arg = *fetch_args(3)
          case command
          when 'matches'
            field_args = [name, :matches, Regexp.new(arg)]
            return Filter.new(inverse: inverse, command: :field, args: field_args )
          when 'min'
            value = Float(arg)
            field_args = [name, :min, value]
            return Filter.new(inverse: inverse, command: :field, args: field_args )
          when 'max'
            value = Float(arg)
            field_args = [name, :max, value]
            return Filter.new(inverse: inverse, command: :field, args: field_args )
          else
            raise "Unknown argument '#{cmd}' to 'field'."
          end
        when 'percent'
          value = Integer(fetch_args(1).first)
          return Filter.new(inverse: inverse, command: :percent, args: value)
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
      @inverse = filter[:inverse]
      @command = filter[:command]
      @args = filter[:args]
    end

    
    # True if filter match event
    def match? event
      if @inverse
        not real_match? event
      else
        real_match? event
      end
    end

    private

    def real_match? event
      case @command
      when :from
        return false if event.time < @args
      when :to
        return false if event.time > @args
      when :field
        name, command, arg = *@args
        case command
        when :matches
          return false unless arg.match( event[name] )
        when :min
          return false unless Float(event[name]) >= arg
        when :max
          return false unless Float(event[name]) <= arg
        end
      when :percent
        return false unless Random.rand <= Float(@args)/100
      end
      true
    end

  end
end
