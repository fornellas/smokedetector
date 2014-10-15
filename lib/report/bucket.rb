require 'parsing'

class Bucket

  extend Parsing

  def self.parse args
    @args = args
    case @args.first
    when 'field'
      field = fetch_args(1).first
      return Bucket.new(bucket: :field, field: field)
    when 'minute'
      @args.shift
      return Bucket.new(bucket: :time, seconds: 60)
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

  private

  # field

  def field_init options
    @field = options[:field]
  end

  def field_name
    @field
  end

  def field_get event
    event[@field]
  end

  # time

  def time_init options
    @seconds = options[:seconds]
  end

  def time_name
    'time'
  end

  def time_get event
    event.time - ( event.time.to_i % @seconds )
  end

end