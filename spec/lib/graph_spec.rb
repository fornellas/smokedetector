require 'graph'
require 'matrix'

describe Graph do
  context '#print' do
  	report = Matrix[
      ['response_time', '/a', '/b'],
      [0,  2, 1],
      [1,  5, 2],
      [2,  3, 3],
      [3,  2, 5],
  		]
  	graph = Graph.new report
  	graph.show
  end
end