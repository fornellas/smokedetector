require 'graph'
require 'matrix'

describe Graph do
  context '#print' do
    include_context 'http type'
    include_context 'parser http'

    before(:example) do
      query = Query.new parser_http
      @report = Report.new(query)
    end

    it 'works with x as strings' do
      report = ['minimum', 'response_time/url', 'by', 'minute']
      graph = Graph.new @report.where(report)
      graph.fprint STDERR
    end

    xit 'works with x as numbers' do

    end

    xit 'works with x as time' do

    end

    xit "compacts report to fit terminal size" do

    end

    xit 'works with single column reports' do

    end

    xit 'works with multiple columns reports' do

    end

    xit 'should throw exeption if terminal width is small' do

    end

    xit 'should throw exeption if terminal height is small' do

    end

    xit 'should throw exception if io is not a terminal' do
      
    end

    xit 'works with negative numbers' do |variable|
      
    end

  end
end