# Common methods for parsing
module Parsing
  # Return an array of 'count' arguments from @args, starting at 1.
  def fetch_args count
    cli = @args.shift(1+count)
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