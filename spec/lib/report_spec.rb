require 'report'

describe Report do
  include_context 'http type'
  include_context 'parser http'

  before(:example) do
    query = Query.new parser_http
    @report = Report.new(query)
  end

  context "#where" do
    context 'stat funcitons' do
      [
        # average
        {
          report: ['average','response_time','by','field', 'url'],
          result: [
            ['url', 'average response_time'],
            ['/a',  7/3.0],
            ['/b',  9/4.0],
            ],
          },
        {
          report: ['average','response_time/status','by','field', 'url'],
          result: [
            ['url', '200', '500'],
            ['/a',  7/3.0, nil],
            ['/b',  3/2.0, 6/2.0],
            ],
          },
        # count
        {
          report: ['count', 'events', 'by', 'field', 'url'],
          result: [
            ['url', 'count events'],
            ['/a',  3],
            ['/b',  4],
            ],
          },
        {
          report: ['count', 'events/status', 'by', 'field', 'url'],
          result: [
            ['url', '200', '500'],
            ['/a',  3, nil],
            ['/b',  2, 2],
            ],
          },
        # uniq_count
        {
          report: ['uniq_count', 'status', 'by', 'field', 'url'],
          result: [
            ['url', 'uniq_count status'],
            ['/a',  1],
            ['/b',  2],
            ],
          },
        {
          report: ['uniq_count', 'status/url', 'by', 'minute'],
          result: [
            ['time',                        '/a', '/b'],
            [Time.parse('Sep 13 16:05:00'), 1,    1],
            [Time.parse('Sep 13 16:06:00'), 1,    1],
            [Time.parse('Sep 13 16:07:00'), 0,    2],
            ],
          },
        # maximum
        {
          report: ['maximum', 'response_time', 'by', 'field', 'url'],
          result: [
            ['url', 'maximum response_time'],
            ['/a',  3],
            ['/b',  5],
            ],
          },
        {
          report: ['maximum', 'response_time/url', 'by', 'minute'],
          result: [
            ['time',                        '/a',      '/b'],
            [Time.parse('Sep 13 16:05:00'), 3,          5],
            [Time.parse('Sep 13 16:06:00'), 3,          1],
            [Time.parse('Sep 13 16:07:00'), nil, 2],
            ],
          },
        # minimum
        {
          report: ['minimum', 'response_time', 'by', 'field', 'url'],
          result: [
            ['url', 'minimum response_time'],
            ['/a',  1],
            ['/b',  1],
            ],
          },
        {
          report: ['minimum', 'response_time/url', 'by', 'minute'],
          result: [
            ['time',                        '/a',      '/b'],
            [Time.parse('Sep 13 16:05:00'), 1,          5],
            [Time.parse('Sep 13 16:06:00'), 3,          1],
            [Time.parse('Sep 13 16:07:00'), nil, 1],
            ],
          },
        # median
        # mode
        # sum
        {
          report: ['sum', 'response_time', 'by', 'field', 'url'],
          result: [
            ['url', 'sum response_time'],
            ['/a',  7],
            ['/b',  9],
            ],
          },
        {
          report: ['sum', 'response_time/url', 'by', 'minute'],
          result: [
            ['time',                        '/a',      '/b'],
            [Time.parse('Sep 13 16:05:00'), 4,          5],
            [Time.parse('Sep 13 16:06:00'), 3,          1],
            [Time.parse('Sep 13 16:07:00'), nil, 3],
            ],
          },
        ].each do |ex|
        example ex[:report].join(' ') do
          result = @report.where(ex[:report])
          expected_result = Matrix[*ex[:result]]
          expect(result).to eq(expected_result)
        end
      end
    end

    context 'bucket funcitons' do
      [
        # field
        {
          report: ['average','response_time','by','field', 'url'],
          result: [
            ['url', 'average response_time'],
            ['/a',  7/3.0],
            ['/b',  9/4.0],
            ],
          },
        # partition
        {
          report: ['count','events','by','partition', 'response_time', '2'],
          result: [
            ['response_time', 'count events'],
            [0,  3],
            [2,  3],
            [4,  1],
            ],
          },
        # second
        {
          report: ['count', 'events', 'by', 'second'],
          result: [
            ['time',                        'count events'],
            [Time.parse('Sep 13 16:05:01'), 1],
            [Time.parse('Sep 13 16:05:02'), 1],
            [Time.parse('Sep 13 16:05:03'), 1],
            [Time.parse('Sep 13 16:06:01'), 1],
            [Time.parse('Sep 13 16:06:02'), 1],
            [Time.parse('Sep 13 16:07:01'), 1],
            [Time.parse('Sep 13 16:07:02'), 1],

            ],
          },
        # minute
        {
          report: ['count', 'events/url', 'by', 'minute'],
          result: [
            ['time',                        '/a', '/b'],
            [Time.parse('Sep 13 16:05:00'), 2,    1],
            [Time.parse('Sep 13 16:06:00'), 1,    1],
            [Time.parse('Sep 13 16:07:00'), nil,    2],
            ],
          },
        # hour
        {
          report: ['count', 'events/url', 'by', 'hour'],
          result: [
            ['time',                        '/a', '/b'],
            [Time.parse('Sep 13 16:00:00'), 3,    4],
            ],
          },
        ].each do |ex|
        example ex[:report].join(' ') do
          result = @report.where(ex[:report])
          expected_result = Matrix[*ex[:result]]
          expect(result).to eq(expected_result)
        end
      end
    end

  end
end
