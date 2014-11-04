require 'query'
require 'parser'
require 'report'
require 'graph'
require 'matrix'

describe Graph do
  context '#print' do
    include_context 'http type'
    include_context 'parser http'

    before(:example) do
      query = Query.new parser_http
      @report = Report.new(query)
      @io = instance_double('IO')
      allow(@io).to receive(:write)
    end

    xit 'should return the same string sent to io' do

    end

    xit 'should throw exception if io is not a terminal' do

    end

    context 'header' do

      before(:example) do
        report = ['count', 'events/status', 'by', 'field', 'url']
        @graph = Graph.new @report.where(report)
      end

      it "should throw exception if terminal is too narrow" do
        allow(@io).to receive(:winsize).and_return([20, 7])
        expect{ @graph.fprint @io }.to raise_error
      end

      it "shouhld not throw expeption if terminal is wide enough" do
        allow(@io).to receive(:winsize).and_return([20, 8])
        expect{ @graph.fprint @io }.not_to raise_error
      end

      it "should print labels in single line if terminal is big enough" do
        allow(@io).to receive(:winsize).and_return([20, 13])
        str = @graph.fprint @io
        header = str.split("\n").first(3).join("\n")+"\n"
        expect(header).to eq("+---+-------+\n|url|\e[32m200\e[0m \e[33m500\e[0m|\n+---+-------+\n")
      end

      context 'multi line area names' do
        it "shoult work breaking label name in half" do
          allow(@io).to receive(:winsize).and_return([20, 12])
          str = @graph.fprint @io
          header = str.split("\n").first(4).join("\n")+"\n"
          expect(header).to eq("+---+------+\n|url|\e[32m200\e[0m \e[33m50\e[0m|\n|   |\e[33m0\e[0m     |\n+---+------+\n")
        end
        it 'should work without breaking label name in half' do |variable|
          allow(@io).to receive(:winsize).and_return([20, 10])
          str = @graph.fprint @io
          header = str.split("\n").first(4).join("\n")+"\n"
          expect(header).to eq("+---+----+\n|url|\e[32m200\e[0m |\n|   |\e[33m500\e[0m |\n+---+----+\n")
        end
      end

    end

    context 'columns' do
      xit "consolidate columns if there are too many" do

      end

      xit 'works with single column reports' do

      end

      xit 'works with multiple columns reports' do

      end
    end

    context 'rows' do
      xit 'should throw exeption if terminal height is small' do

      end

      xit 'works with x as strings' do

      end

      xit 'works with x as numbers' do

      end

      xit 'works with x as time' do

      end

      xit 'works with negative numbers' do

      end
    end

  end
end