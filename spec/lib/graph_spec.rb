require 'query'
require 'parser'
require 'report'
require 'graph'
require 'matrix'
require 'report/data'

describe Graph do

  let(:graph) do
    report_data = Report::Data.new(
      matrix: [
        ["time", "-", "Feedly/1.0 (+http://www.feedly.com/fetcher.html; like FeedFetcher-Google)", "Mozilla/5.0 (Linux) csyncoC/0.91.5 neon/0.30.0",
      "Mozilla/5.0 (Linux) mirall/1.6.4", "NewRelicPinger/1.0 (763197)",
      "Tiny Tiny RSS/1.14 (http://tt-rss.org/)", "Valve/Steam HTTP Client 1.0",
      "android-cloud-api - Android 4.4.2"],
        [Time.parse("2014-11-04 18:00:00 -0200"), 2, 2, 12, 225, 120, 11, 6, 0],
        [Time.parse("2014-11-04 19:00:00 -0200"), 6, 0, 11, 226, 120, 12, 0, 20],
        [Time.parse("2014-11-04 20:00:00 -0200"), 3, 1, 7, 131, 71, 6, 0, 0]
        ],
      size: 3600.0,
      type: :time,
      )
    Graph.new(report_data)
  end

  context '#fprint' do

    it 'writes graph to io'

    it 'throws exception if io is not a terminal' do
      expect do
        graph.fprint(File.new('/dev/null'))
      end.to raise_error(Errno::ENOTTY)
    end

    it 'throws exception if terminal is short'
    it 'works with all positive numbers'
    it 'works with all negative numbers'
    it 'works with positive and negative numbers'

    xcontext 'STDERR IO test' do

      example "sample", :focus do
        allow($stderr).to receive(:winsize).and_return([24, 80])
        puts '------------------'
        graph.fprint $stderr
        puts '------------------'
        pending 'just a test'
      end
    end
  end

  context 'Private instance method' do

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
      it 'draws header' do
        sio = StringIO.new
        allow(sio).to receive(:winsize).and_return([24,80])
        header = graph.instance_eval do
          @io = sio
          get_terminal_attrs
          new_graph min_label_width
          compact_areas
          draw_header
          @buffer
        end
        expect(header).to eq("+----+-------------------------------------------------------------------------+\n|time|\e[35m-\e[0m \e[34mFeedly/1.0 (+http://www.feedly.com/fetcher.html; like FeedFetcher-Googl\e[0m|\n|    |\e[34me)\e[0m \e[36mMozilla/5.0 (Linux) csyncoC/0.91.5 neon/0.30.0\e[0m \e[32mMozilla/5.0 (Linux) mir\e[0m|\n|    |\e[32mall/1.6.4\e[0m \e[33mNewRelicPinger/1.0 (763197)\e[0m \e[31mothers\e[0m                             |\n+----+-------------------------------------------------------------------------+\n")
      end
    end

    context '#compact_rows' do
      it 'does not compact if there is space'

      it 'works with type: :field' do
        report_data = Report::Data.new(
          matrix: [
            ['url', '200', '400','500'],
            ['/a',  3, 1, 3],
            ['/b',  2, 2, 3],
            ['/c',  2, 0, 2],
            ],
          type: :field,
          size: nil,
          )
        compact_report_data = Report::Data.new(
          matrix: [
            ['url', '200', '400','500'],
            ['/a',  3, 1, 3],
            ['others',  4, 2, 5],
            ],
          type: :field,
          size: nil,
          )
        graph = Graph.new(report_data)
        allow(graph).to receive(:max_rows_height).and_return(2)
        compact_rows_return = graph.instance_eval do
          @report_data = report_data
          compact_rows
          @report_data
        end
        expect(compact_rows_return).to eq(compact_report_data)
      end

      it 'works with type: :partition'

      it 'works with type: :time'

    end

    context '#header_height' do
      it 'calculate current header height' do
        header_height_return = graph.instance_eval do
          @buffer = "+----+-------------------------------------------------------------------------+\n|time|\e[35m-\e[0m \e[34mFeedly/1.0 (+http://www.feedly.com/fetcher.html; like FeedFetcher-Googl\e[0m|\n|    |\e[34me)\e[0m \e[36mMozilla/5.0 (Linux) csyncoC/0.91.5 neon/0.30.0\e[0m \e[32mMozilla/5.0 (Linux) mir\e[0m|\n|    |\e[32mall/1.6.4\e[0m \e[33mNewRelicPinger/1.0 (763197)\e[0m \e[31mothers\e[0m                             |\n+----+-------------------------------------------------------------------------+\n"
          header_height
        end
        expect(header_height_return).to eq(5)
      end
    end

    context '#scale_height' do
      it 'returns 1' do
        expect(graph.instance_eval{scale_height}).to eq(1)
      end
    end

    context '#max_rows_height' do

      before(:example) do
        expect(graph).to receive(:header_height).and_return(5)
        expect(graph).to receive(:scale_height).and_return(1)
      end

      it 'calculates maximum number of rows' do
        max_rows_height_return = graph.instance_eval do
          @terminal_height = 10
          max_rows_height
        end
        expect(max_rows_height_return).to eq(3)
      end

      it 'returns a minimum of 2 rows' do
        max_rows_height_return = graph.instance_eval do
          @terminal_height = 5
          max_rows_height
        end
        expect(max_rows_height_return).to eq(2)
      end

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

      it 'compacts @report_data if it has more areas than #max_areas' do
        allow(graph).to receive(:max_areas).and_return(3)
        compact_report_data = graph.instance_eval do
          new_graph 10
          compact_areas
          @report_data
        end
        expect(compact_report_data.matrix).to eq(
          [
            ["time", "-", "Feedly/1.0 (+http://www.feedly.com/fetcher.html; like FeedFetcher-Google)","others"],
            [Time.parse("2014-11-04 18:00:00 -0200"), 2, 2, 374],
            [Time.parse("2014-11-04 19:00:00 -0200"), 6, 0, 389],
            [Time.parse("2014-11-04 20:00:00 -0200"), 3, 1, 215]
            ])
      end

      it 'does not compact @report_data if it has less or equal areas than #max_areas' do
        allow(graph).to receive(:max_areas).and_return(9)
        compact_report_data = graph.instance_eval do
          new_graph 10
          compact_areas
          @report_data
        end
        expect(compact_report_data.matrix).to eq(graph.instance_eval{@original_report_data.matrix})
      end

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