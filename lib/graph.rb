class Graph

  def initialize report
    @report = report
  end

  def show
    puts bucket 0
    (1...@report.row_count).each do |row|
      print "#{bucket row} "
      (1...@report.column_count).each do |column|
        (0...@report[row, column]).each {|value| print symbol(column)}
      end
      puts ''
    end
  end

  private

  def bucket row
    @report[row, 0]
  end

  def symbol count
    ['-', '='][count-1]
  end

end