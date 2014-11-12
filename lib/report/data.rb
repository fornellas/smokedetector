class Report
  class Data
    attr_accessor :matrix, :type, :size
    def initialize opts
      @matrix = opts[:matrix]
      @type = opts[:type]
      @size = opts[:size]
    end
  end
end