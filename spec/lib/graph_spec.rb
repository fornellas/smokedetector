require 'query'
require 'parser'
require 'report'
require 'graph'
require 'matrix'
require 'report/data'

describe Graph do
  context '#fprint' do

    context 'STDERR IO' do
      include_context 'nginx type'
      include_context 'parser nginx'
      example "sample", :focus do
        query = Query.new parser_nginx
        report = Report.new(query)
        stat_by_bucket = ['count', 'events/http_user_agent', 'by', 'hour']
        graph = Graph.new(report.where(stat_by_bucket))
        allow($stderr).to receive(:winsize).and_return([24, 80])
        puts
        graph.fprint $stderr
        puts
        pending
      end
    end
  end
end