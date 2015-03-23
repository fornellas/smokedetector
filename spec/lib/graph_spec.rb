require 'query'
require 'parser'
require 'report'
require 'graph'
require 'matrix'
require 'report/data'

describe Graph do
  context '#fprint' do

    include_context 'nginx type'
    include_context 'parser nginx'

    let(:graph) do
      query = Query.new parser_nginx
      report = Report.new(query)
      stat_by_bucket = ['count', 'events/http_user_agent', 'by', 'hour']
      Graph.new(report.where(stat_by_bucket))
    end

    it 'writes graph to io'

    it 'throws exception if io is not a terminal' do
      expect do
        graph.fprint(File.new('/dev/null'))
      end.to raise_error(Errno::ENOTTY)
    end

    it 'throws exception if terminal is small'
    it 'works with all positive numbers'
    it 'works with all negative numbers'
    it 'works with positive and negative numbers'
    it 'compacts rows with type :field'
    it 'compacts rows with type :partition'
    it 'compacts rows with type :time'

    # context 'STDERR IO test' do

    #   example "sample", :focus do

    #     allow($stderr).to receive(:winsize).and_return([24, 80])
    #     puts
    #     graph.fprint $stderr
    #     puts
    #     pending
    #   end
    # end
  end
end