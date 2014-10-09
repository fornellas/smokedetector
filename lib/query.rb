require 'event'
require 'query/filter'

# Query events from Parser class
class Query

  include Enumerable

  # Create new query object from Parser object.
  def initialize parser
    @parser = parser
    @query = nil
  end

  # Yields each event found to given block.
  def each
    @parser.each do |event|
      yield event if match? event
    end
  end

  # Filter events matching given criteria.
  def where query
    @query = Filter.parse(query)
    self
  end

  private
 
  # Return true if given event matches all filters at @*_filters.
  def match? event
    @query.each do |query|
      if query.inverse?
        return false if query.match? event
      else
        return false unless query.match? event
      end
    end
    true
  end

end
