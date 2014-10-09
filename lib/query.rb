require 'event'
require 'query/filter'

# Query events from Parser class
class Query

  include Enumerable

  # Create new query object from Parser object.
  def initialize parser
    @parser = parser
    @filters = []
  end

  # Yields each event found to given block.
  def each
    @parser.each do |event|
      yield event if match? event
    end
  end

  # Filter events matching given criteria.
  def where query
    @filters = Filter.parse(query)
    self
  end

  private
 
  # Return true if given event matches all filters at @*_filters.
  def match? event
    @filters.each do |filter|
      return false unless filter.match? event
    end
    true
  end

end
