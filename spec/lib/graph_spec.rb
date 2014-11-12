require 'query'
require 'parser'
require 'report'
require 'graph'
require 'matrix'
require 'report/data'

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

    context 'rows' do
      include_context 'nginx type'
      include_context 'parser nginx'

      before(:example) do
        query = Query.new parser_nginx
        @report = Report.new(query)
        @io = instance_double('IO')
        allow(@io).to receive(:write)
      end

      xexample "with all positive numbers" do
          # report = ['sum','body_bytes_sent','by','field', 'status']
          # graph = Graph.new(@report.where(report))
          # allow(@io).to receive(:winsize).and_return([40, 30])
          # str = graph.fprint @io
          # $stderr << str
          # pp str
      end

      xexample 'with positive and negative numbers' do

      end

      xexample 'with all negative numbers' do

      end
    end

    context 'legend' do
      xexample "with all positive numbers" do
        
      end

      xexample "with positive and negative numbers" do
        
      end

      xexample "with all negative numbers" do
        
      end
    end

    context 'private methods' do
      before(:example) do
        @report_data = Report::Data.new(
          matrix: Matrix[
            ['url', '200', '400','500'],
            ['/a',  3, 1, 3],
            ['/b',  2, 2, 2],
            ],
          type: :string,
          size: nil,
          )
        @graph = Graph.new(@report_data)
      end

      context '#compact_columns' do
        it 'should compact columns greater than max_columns' do
          allow(@graph).to receive(:max_columns).and_return(2)
          compact_report = @graph.instance_eval do
            compact_columns
            @report_data
          end
          expect(compact_report.matrix).to eq(
            Matrix[
              ["url", "200", "others"],
              ["/a", 3, 4],
              ["/b", 2, 4]
              ]
            )
        end

        it "should not compact rows if column count is less or equal to max_columns" do
          allow(@graph).to receive(:max_columns).and_return(3)
          compact_report_data = @graph.instance_eval do
            compact_columns
            @report_data
          end
          expect(compact_report_data.matrix).to eq(@report_data.matrix)
        end
      end

      context '#compact_rows' do
        before(:example) do
          @report_data = Report::Data.new(
            matrix: Matrix[
              ['url', '200', '400','500'],
              ['/a',  3, 1, 3],
              ['/b',  2, 2, 2],
              ['/c',  2, 0, 2],
              ],
            type: :string,
            size: nil,
            )
          @graph = Graph.new(@report_data)
        end

        it "should compact rows if row count is bigger than #available_rows" do
          allow(@graph).to receive(:available_rows).and_return(2)
          compact_report_data = @graph.instance_eval do
            compact_rows
            @report_data
          end
          expect(compact_report_data.matrix).to eq(
            Matrix[
              ['url',    '200', '400','500'],
              ['/a',     3, 1, 3],
              ['others', 4, 2, 4],
              ]
            )
        end

        it "should not compact rows if row count is less or equal to #available_rows" do
          allow(@graph).to receive(:available_rows).and_return(3)
          compact_report_data = @graph.instance_eval do
            compact_rows
            @report_data
          end
          expect(compact_report_data.matrix).to eq(@report_data.matrix)
        end
      end

      context '#rescale_rows' do
        include_context 'nginx type'
        include_context 'parser nginx'

        it "should rescale rows to fill #available_rows" do
          query = Query.new parser_nginx
          report = Report.new(query)
          io = instance_double('IO')
          allow(io).to receive(:write)
          where_query = ['sum','body_bytes_sent/status','by','partition', 'body_bytes_sent', '1000']
          report_data = report.where(where_query)
          graph = Graph.new(report_data)
          allow(io).to receive(:winsize).and_return([9, 50])
          allow(graph).to receive(:available_rows).and_return(4)
          graph.fprint io
          rescaled_report_data = graph.instance_eval do
            rescale_rows
            @report_data
          end
          expect(rescaled_report_data.matrix).to eq(
            Matrix[
              ["body_bytes_sent", "200", "207", "301", "400", "401", "others"],
              [0.0, 2589076.0, 575011.0, 552.0, 0.0, 304.0, 7436.0],
              [14687.5, 0, 0, 0, 0, 0, 0],
              [29375.0, 0, 0, 0, 0, 0, 0],
              [44062.5, 1451940.0, 0, 0, 0, 0, 0]
              ]
            )
        end
      end

      context '#available_rows' do
        before(:example) do
          report = Matrix[
            ['url', '200', '400','500'],
            ['/a',  3, 1, 3],
            ['/b',  2, 2, 2],
            ['/c',  2, 0, 2],
            ]
          @graph = Graph.new(report)
        end

        it "should report rows available to be printed depending on @terminal_height, headers and scale" do
          rows = @graph.instance_eval do
            @buffer = "+------+---------------------+\n|status|\e[35msum body_bytes_sent\e[0m  |\n+------+---------------------+\n"
            @terminal_height = 7
            available_rows
          end
          expect(rows).to eq(2)
        end

        it 'should throw exeption if terminal height is small' do
          expect do
            @graph.instance_eval do
              @buffer = "+------+---------------------+\n|status|\e[35msum body_bytes_sent\e[0m  |\n+------+---------------------+\n"
              @terminal_height = 5
              available_rows
            end
          end.to raise_error
        end
      end
    end
  end
end