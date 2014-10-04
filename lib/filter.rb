require 'event'

# Filter events from Parser class
class Filter

  def initialize parser
    @parser = parser
  end

  # Filter events and yields each resulting event to given block.  
  def where params
    @parser.each do |event|
      params.each do |field, value|
        if field == 'time'
        else
          if event[field] =~ value
            yield event
          end
        end
      end
    end
  end

end
