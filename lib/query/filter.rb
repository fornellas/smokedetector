require 'parsing'

class Query
  class Filter
    extend Parsing

    # Parse filters and return an array of Filter objects, consuming only known
    # arguments from query array.
    def self.parse args
      @args = args
      @filters = []
      until @args.empty?
        filter = nil
        if @args.first == 'not'
          raise "Missing arguments after 'not'." if @args.size < 2
          @args.shift
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

    # Return Filter after parsing @args
    def self.get_filter inverse
      until @args.empty?
        case @args.first
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
