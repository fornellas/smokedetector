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

    it 'throws exception if terminal is narrow'
    it 'throws exception if terminal is short'
    it 'works with all positive numbers'
    it 'works with all negative numbers'
    it 'works with positive and negative numbers'
    it 'compacts rows with type :field'
    it 'compacts rows with type :partition'
    it 'compacts rows with type :time'

    xcontext 'STDERR IO test' do

      example "sample", :focus do

        allow($stderr).to receive(:winsize).and_return([24, 80])
        puts
        graph.fprint $stderr
        puts
        pending 'just a test'
      end
    end
  end

  context 'Private instance method' do

    include_context 'nginx type'
    include_context 'parser nginx'

    let(:graph) do
      query = Query.new parser_nginx
      report = Report.new(query)
      stat_by_bucket = ['count', 'events/http_user_agent', 'by', 'hour']
      Graph.new(report.where(stat_by_bucket))
    end

    context '#get_terminal_attrs' do
      before(:example) do
        console_double = double("IO", winsize: [24, 80])
        graph.instance_eval{@io = console_double}
      end
      it 'saves terminal data to @terminal_height, @terminal_width' do
        graph.instance_eval{get_terminal_attrs}
        expect(graph.instance_eval{[@terminal_height, @terminal_width]})
          .to eq([24, 80])
      end

      it 'raises if width is smaller than #min_terminal_width' do
        allow(graph).to receive(:min_terminal_width).and_return(81)
        expect{graph.instance_eval{get_terminal_attrs}}.to raise_error(Graph::SmallTerminal)
      end
    end

    context '#draw_header' do
      it 'draws single line header'
      it 'draws multi line headers'
    end

    context '#horiz_divider' do
      before(:example) do
        console_double = double("IO", winsize: [10, 10])
        graph.instance_eval do
          @io = console_double
          @buffer = ''
          @label_width = 4
          get_terminal_attrs
        end
      end
      it 'draws a horizontal divider' do
        graph.instance_eval{horiz_divider}
        expect(graph.instance_eval{@buffer}).to eq("+----+---+\n")
      end
    end

    context '#label' do
      before(:example) do
        graph.instance_eval do
          @label_width = 5
          @biggest_label_width = 0
        end
      end
      it 'trim big strings to fit @label_width' do
        expect(graph.instance_eval{label "123456"}).to be == "12..."
      end

      it 'add spaces to short strings to fill @label_width' do
        expect(graph.instance_eval{label "1"}).to be == "1    "
      end
      it 'updates @biggest_label_width if str is bigger' do
        expect{graph.instance_eval{label "12345"}}
          .to change{graph.instance_eval{@biggest_label_width}}
          .from(0).to(5)
      end
      it 'does not update @biggest_label_width if str is smaller' do
        graph.instance_eval{@biggest_label_width = 5}
        expect{graph.instance_eval{label "12345"}}
          .not_to change{graph.instance_eval{@biggest_label_width}}
      end
    end

    context '#compact_areas' do
      # TODO
      it 'compacts @report_data if it has more areas than #max_areas'
      it 'does not compact @report_data if it has less or equal areas than #max_areas'
    end

    context '#max_areas' do
      it 'returns the number of AREA_COLORS' do
        number_of_area_colors = graph.instance_eval{Graph::AREA_COLORS.size}
        expect(graph.instance_eval{max_areas}).to eq(number_of_area_colors)
      end
    end

    context '#max_label_width' do
      before(:example) do
        console_double = double("IO", winsize: [24, 80])
        graph.instance_eval do
          @io = console_double
          @buffer = ''
          get_terminal_attrs
        end
      end
      it 'returns half terminal size' do
        expect(graph.instance_eval{max_label_width}).to eq(38)
      end
    end

    context '#min_label_width' do
      it 'returns size of "L..."' do
        expect(graph.instance_eval{min_label_width}).to eq("L...".size)
      end
    end

    context '#min_graph_width' do
      it 'returns size of "#|#"' do
        expect(graph.instance_eval{min_graph_width}).to eq("#|#".size)
      end
    end

  end
end