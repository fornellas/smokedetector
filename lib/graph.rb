#require 'io/console'
require 'report/data'

class Graph

  # Receive Report::Data object.
  def initialize report_data
    @report_data = report_data
  end

  # Write graph to given IO object, which must respond to #winsize.
  def fprint io
    io.write @report_data.matrix
  end

  private



end