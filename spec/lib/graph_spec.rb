require 'query'
require 'parser'
require 'report'
require 'graph'
require 'matrix'

describe Graph do
  context '#print' do
    context 'simple data' do
      include_context 'http type'
      include_context 'parser http'

      before(:example) do
        query = Query.new parser_http
        @report = Report.new(query)
        @io = instance_double('IO')
        allow(@io).to receive(:write)
      end

      it 'should return the same string sent to io' do
        report = ['count', 'events/status', 'by', 'field', 'url']
        @graph = Graph.new @report.where(report)
        @str = nil
        expect do
          allow($stderr).to receive(:winsize).and_return([20, 13])
          @str = @graph.fprint $stderr
        end.to output(@str).to_stderr
      end

      it 'should throw exception if io is not a terminal' do
        File.open('/dev/null', 'w') do |io|
          report = ['count', 'events/status', 'by', 'field', 'url']
          @graph = Graph.new @report.where(report)
          expect do
            @graph.fprint io
          end.to raise_error(Errno::ENOTTY)
        end
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
          expect(header).to eq("+---+-------+\n|url|\e[35m200\e[0m \e[34m500\e[0m|\n+---+-------+\n")
        end

        context 'multi line area names' do
          it "should work breaking label name in half" do
            allow(@io).to receive(:winsize).and_return([20, 12])
            str = @graph.fprint @io
            header = str.split("\n").first(4).join("\n")+"\n"
            expect(header).to eq("+---+------+\n|url|\e[35m200\e[0m \e[34m50\e[0m|\n|   |\e[34m0\e[0m     |\n+---+------+\n")
          end
          it 'should work without breaking label name in half' do |variable|
            allow(@io).to receive(:winsize).and_return([20, 10])
            str = @graph.fprint @io
            header = str.split("\n").first(4).join("\n")+"\n"
            expect(header).to eq("+---+----+\n|url|\e[35m200\e[0m |\n|   |\e[34m500\e[0m |\n+---+----+\n")
          end
        end
      end
    end

    context 'complex data' do
      include_context 'nginx type'
      include_context 'parser nginx'

      before(:example) do
        query = Query.new parser_nginx
        @report = Report.new(query)
        @io = instance_double('IO')
        allow(@io).to receive(:write)
      end

      context 'columns' do
        xit 'works with single column reports' do

        end

        xit 'works with multiple columns reports' do

        end
      end

      context 'rows' do
        xit 'should throw exeption if terminal height is small' do

        end

        xit 'works with rows as strings' do
          report = ['count','events/status','by','field', 'hour']
          graph = Graph.new(@report.where(report))
          allow(@io).to receive(:winsize).and_return([20, 40])
          str = graph.fprint @io
        end

        xit 'works with rows as numbers' do

        end

        xit 'works with rows as time' do

        end

        xit 'works with negative numbers' do

        end
      end
    end

    context 'private methods' do
      context '#compact_columns' do
        it 'should compact columns greater than max_columns to a "others"' do
          report = Matrix[
            ['url', '200', '400','500'],
            ['/a',  3, 1, 3],
            ['/b',  2, 2, 2],
            ]
          graph = Graph.new(report)
          allow(graph).to receive(:max_columns).and_return(2)
          compact_report = graph.instance_eval do
            compact_columns
            @report
          end
          expect(compact_report).to eq(
            Matrix[
              ["url", "200", "others"],
              ["/a", 3, 4], ["/b", 2, 4]
              ]
            )
        end
      end
    end
  end
end