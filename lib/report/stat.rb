require 'parsing'

class Stat

  extend Parsing

  attr_accessor :bucket

  # Parse stat function and return Stat object, consuming only known
  # arguments from report array.
  def self.parse args
    @args = args
    case @args.first
    when 'average', 'count', 'uniq_count'
      stat = @args.first.to_sym
      @fields = fetch_args(1).first
      return Stat.new(stat, *fetch_fields)
    else
      raise "Unknown stat command '#{@args.first}'"
    end

  end

  private

  # Return array of field, over parsing @fields
  def self.fetch_fields
    case (split = @fields.split('/')).size
    when 1
      return [split.first, nil]
    when 2
      return split
    else
      raise "Multiple fields specified: '#{@fields}'."
    end
  end

  public

  def initialize stat, field, over=nil
    @stat = stat
    @field = field
    @over = over
    @headers = []
    send("#{@stat}_init".to_sym)
  end

  def headers
    unless @over
      ["#{@stat} #{@field}"]
    else
      [*@headers].sort
    end
  end

  def add event
    @event = event
    send("#{@stat}_add".to_sym)
  end

  def each &block
    if @over
      @bucket.list.each do |bucket|
        values = []
        headers.each do |header|
          key = [bucket, header]
          values << send("#{@stat}_consolidate".to_sym, key)
        end
        yield [bucket, *values]
      end
    else
      @bucket.list.each do |key|
        yield [key, send("#{@stat}_consolidate".to_sym, key)]
      end
    end
  end

  private

  # Return stat key, based on @bucket, @event and @over. Also populate @headers.
  def add_key
    bucket = @bucket.get(@event)
    if @over
      header = @event[@over]
      @headers << header unless @headers.include? header
      return [bucket, header]
    else
      return bucket
    end
  end

  # average

  def average_init
    @counter = {}
    @sum = {}
  end

  def average_add
    @counter[add_key] ||= 0
    @counter[add_key] += 1
    @sum[add_key] ||= 0.0
    @sum[add_key] += Float(@event[@field])
  end

  def average_consolidate key
    if @sum[key]
      @sum[key]/@counter[key]
    else
      Float::NAN
    end
  end

  # count

  def count_init
    unless @field == 'events'
      raise "Invalid argument '#{@field}' to counter: must be 'events'."
    end
    @counter = {}
  end

  def count_add
    @counter[add_key] ||= 0
    @counter[add_key] += 1
  end

  def count_consolidate key
    if @counter[key]
      @counter[key]
    else
      Float::NAN
    end
  end

  # uniq_count

  def uniq_count_init
    @list = {}
  end

  def uniq_count_add
    @list[add_key] ||= []
    unless @list[add_key].include? @event[@field]
      @list[add_key] << @event[@field]
    end
  end

  def uniq_count_consolidate key
    if @list[key]
      @list[key].count
    else
      0
    end
  end

end