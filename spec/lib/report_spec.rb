require 'report'

describe Report do
  include_context 'http type'
  include_context 'parser http'

  let(:report) do
    query = Query.new(parser_http)
    Report.new(query)
  end

  context "#where" do
    context 'stat funcitons' do
      [
        # average
        {
          stat_by_bucket: ['average','response_time','by','field', 'url'],
          result: [
            ['url', 'average response_time'],
            ['/a',  7/3.0],
            ['/b',  9/4.0],
            ],
          },
        {
          stat_by_bucket: ['average','response_time/status','by','field', 'url'],
          result: [
            ['url', '200', '500'],
            ['/a',  7/3.0, 0],
            ['/b',  3/2.0, 6/2.0],
            ],
          },
        # count
        {
          stat_by_bucket: ['count', 'events', 'by', 'field', 'url'],
          result: [
            ['url', 'count events'],
            ['/a',  3],
            ['/b',  4],
            ],
          },
        {
          stat_by_bucket: ['count', 'events/status', 'by', 'field', 'url'],
          result: [
            ['url', '200', '500'],
            ['/a',  3, 0],
            ['/b',  2, 2],
            ],
          },
        # uniq_count
        {
          stat_by_bucket: ['uniq_count', 'status', 'by', 'field', 'url'],
          result: [
            ['url', 'uniq_count status'],
            ['/a',  1],
            ['/b',  2],
            ],
          },
        {
          stat_by_bucket: ['uniq_count', 'status/url', 'by', 'minute'],
          result: [
            ['time',                        '/a', '/b'],
            [Time.parse('Sep 13 16:05:00'), 1,    1],
            [Time.parse('Sep 13 16:06:00'), 1,    1],
            [Time.parse('Sep 13 16:07:00'), 0,    2],
            ],
          },
        # maximum
        {
          stat_by_bucket: ['maximum', 'response_time', 'by', 'field', 'url'],
          result: [
            ['url', 'maximum response_time'],
            ['/a',  3],
            ['/b',  5],
            ],
          },
        {
          stat_by_bucket: ['maximum', 'response_time/url', 'by', 'minute'],
          result: [
            ['time',                        '/a',      '/b'],
            [Time.parse('Sep 13 16:05:00'), 3,          5],
            [Time.parse('Sep 13 16:06:00'), 3,          1],
            [Time.parse('Sep 13 16:07:00'), 0, 2],
            ],
          },
        # minimum
        {
          stat_by_bucket: ['minimum', 'response_time', 'by', 'field', 'url'],
          result: [
            ['url', 'minimum response_time'],
            ['/a',  1],
            ['/b',  1],
            ],
          },
        {
          stat_by_bucket: ['minimum', 'response_time/url', 'by', 'minute'],
          result: [
            ['time',                        '/a',      '/b'],
            [Time.parse('Sep 13 16:05:00'), 1,          5],
            [Time.parse('Sep 13 16:06:00'), 3,          1],
            [Time.parse('Sep 13 16:07:00'), 0, 1],
            ],
          },
        # median
        # mode
        # sum
        {
          stat_by_bucket: ['sum', 'response_time', 'by', 'field', 'url'],
          result: [
            ['url', 'sum response_time'],
            ['/a',  7],
            ['/b',  9],
            ],
          },
        {
          stat_by_bucket: ['sum', 'response_time/url', 'by', 'minute'],
          result: [
            ['time',                        '/a',      '/b'],
            [Time.parse('Sep 13 16:05:00'), 4,          5],
            [Time.parse('Sep 13 16:06:00'), 3,          1],
            [Time.parse('Sep 13 16:07:00'), 0, 3],
            ],
          },
        ].each do |ex|
        example ex[:stat_by_bucket].join(' ') do
          result = report.where(ex[:stat_by_bucket])
          expected_result_matrix = [*ex[:result]]
          expect(result.matrix).to eq(expected_result_matrix)
        end
      end
    end

    context 'bucket funcitons' do
      [
        # field
        {
          stat_by_bucket: ['average','response_time','by','field', 'url'],
          result: [
            ['url', 'average response_time'],
            ['/a',  7/3.0],
            ['/b',  9/4.0],
            ],
          },
        # partition
        {
          stat_by_bucket: ['count','events','by','partition', 'response_time', '2'],
          result: [
            ['response_time', 'count events'],
            [0,  3],
            [2,  3],
            [4,  1],
            ],
          },
        # second
        {
          stat_by_bucket: ['count', 'events', 'by', 'second'],
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
          stat_by_bucket: ['count', 'events/url', 'by', 'minute'],
          result: [
            ['time',                        '/a', '/b'],
            [Time.parse('Sep 13 16:05:00'), 2,    1],
            [Time.parse('Sep 13 16:06:00'), 1,    1],
            [Time.parse('Sep 13 16:07:00'), 0,    2],
            ],
          },
        # hour
        {
          stat_by_bucket: ['count', 'events/url', 'by', 'hour'],
          result: [
            ['time',                        '/a', '/b'],
            [Time.parse('Sep 13 16:00:00'), 3,    4],
            ],
          },
        ].each do |ex|
        example ex[:stat_by_bucket].join(' ') do
          result = report.where(ex[:stat_by_bucket])
          expected_result_matrix = [*ex[:result]]
          expect(result.matrix).to eq(expected_result_matrix)
        end
      end
    end

  end
end
