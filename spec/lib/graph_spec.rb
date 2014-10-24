require 'graph'
require 'matrix'

describe Graph do
  context '#print' do
    before(:example) do
      @report = Matrix[
        ['response_time', '/a', '/b'],
        [0,  0, 5],
        [1,  1, 4],
        [2,  2, 3],
        [5,  3, 2],
    	]
    end

    it "should print a graph" do
      graph = Graph.new @report
      graph.show
    end

    xit "generates stacked graph" do

    end

    xit "generates side by side bar graph" do

    end

    xit "compacts report to fit terminal size" do

    end

    xit 'works with single column reports' do

    end

    xit 'works with multiple columns reports' do

    end

    xit 'works with x as strings' do

    end

    xit 'works with x as numbers' do

    end

    xit 'works with x as time' do

    end

  end
end