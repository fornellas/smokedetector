require 'parsing'

class Bucket

  extend Parsing

  def self.parse args
    @args = args
    case @args.first
    when 'field'
      field = fetch_args(1).first
      return Bucket.new(bucket: :field, field: field)
    else
      raise "Unknown bucket '#{@args.first}'."
    end
  end

  def initialize(options)
    @bucket = options[:bucket]
    @list = []
    case @bucket
    when :field
      @field = options[:field]
    end
  end

  def name
    case @bucket
    when :field
      @field
    end
  end

  def get event
    case @bucket
    when :field
      b = event[@field]
    end
    @list << b unless @list.include? b
    b
  end

  def list
    @list.sort
  end

end