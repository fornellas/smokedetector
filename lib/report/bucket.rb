require 'parsing'

class Bucket

  extend Parsing

  def self.parse args
    @args = args
    case @args.first
    when 'field'
      field = fetch_args(1).first
      return Bucket.new(bucket: :field, field: field)
    when 'second'
      @args.shift
      return Bucket.new(bucket: :time, seconds: 1)
    when 'minute'
      @args.shift
      return Bucket.new(bucket: :time, seconds: 60)
    when 'hour'
      @args.shift
      return Bucket.new(bucket: :time, seconds: 3600)
    when 'partition'
      field, partition_size = *fetch_args(2)
      return Bucket.new(bucket: :partition, field: field, partition_size: partition_size)
    else
      raise "Unknown bucket '#{@args.first}'."
    end
  end

  def initialize(options)
    @bucket = options[:bucket]
    @list = []
    send("#{@bucket}_init".to_sym, options)
  end

  def name
    send("#{@bucket}_name".to_sym)
  end

  def get event
    bucket = send("#{@bucket}_get".to_sym, event)
    @list << bucket unless @list.include? bucket
    bucket
  end

  def list
    @list.sort
  end

  # type: either :string or :continuous
  attr_accessor :type

  # For type = :continuous, return size of each bucket
  attr_accessor :size

  private

  # field

  def field_init options
    @field = options[:field]
    @type = :string
  end

  def field_name
    @field
  end

  def field_get event
    event[@field]
  end

  # partition

  def partition_init options
    @field = options[:field]
    @partition_size = Float(options[:partition_size])
    @type = :continuous
    @size = @partition_size
  end

  def partition_name
    @field
  end

  def partition_get event
    value = Float(event[@field])
    value - ( value % @partition_size )
  end

  # time

  def time_init options
    @seconds = Integer(options[:seconds])
    @type = :continuous
    @size = @seconds.to_f
  end

  def time_name
    'time'
  end

  def time_get event
    event.time - ( event.time.to_i % @seconds )
  end

end