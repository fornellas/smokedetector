require 'event'
require 'query/filter'

# Query events from Parser class
class Query

  include Enumerable

  # Create new query object from Parser object.
  def initialize parser
    @parser = parser
    @include_filters = []
    @exclude_filters = []
  end

  # Yields each event found to given block.
  def each
    @parser.each do |event|
      yield event if match? event
    end
  end

  # Filter events matching given criteria.
  def where *filters
    unless filters.nil?
      @include_filters << Filter.new(*filters)
    end
    self
  end
 
  # Inverse filter, to be chained after #where call.
  def not *filters
    unless filters.nil?
      @exclude_filters << Filter.new(*filters)
    end
    self
  end

  private

  # Return true if given event matches all filters at @*_filters.
  def match? event
    @include_filters.each do |filter|
      return false unless filter.match? event
    end
    @exclude_filters.each do |filter|
      return false if filter.match? event
    end
    true
  end

end
