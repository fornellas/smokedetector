require 'query'
require 'parser'
require 'report'
require 'graph'
require 'matrix'
require 'report/data'

describe Graph do
  context '#fprint' do

    it 'writes graph to io'
    it 'throws exception if io is not a terminal'
    it 'throws exception if terminal is small'
    it 'works with all positive numbers'
    it 'works with all negative numbers'
    it 'works with positive and negative numbers'
    it 'compacts rows with type :field'
    it 'compacts rows with type :partition'
    it 'compacts rows with type :time'

    # context 'STDERR IO test' do
    #   include_context 'nginx type'
    #   include_context 'parser nginx'
    #   example "sample", :focus do
    #     query = Query.new parser_nginx
    #     report = Report.new(query)
    #     stat_by_bucket = ['count', 'events/http_user_agent', 'by', 'hour']
    #     graph = Graph.new(report.where(stat_by_bucket))
    #     allow($stderr).to receive(:winsize).and_return([24, 80])
    #     puts
    #     graph.fprint $stderr
    #     puts
    #     pending
    #   end
    # end
  end
end