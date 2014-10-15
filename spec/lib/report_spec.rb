require 'report'

describe Report do
  include_context 'http type'
  include_context 'parser http'

  before(:example) do
    query = Query.new parser_http
    @report = Report.new(query)
  end

  context "#where" do
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
          ['/a',  7/3.0, Float::NAN],
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
          ['/a',  3, Float::NAN],
          ['/b',  2, 2],
          ],
        },
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
          ['time',                         '/a', '/b'],
          [Time.parse('Sep 13 16:05:00'), 1,    1],
          [Time.parse('Sep 13 16:06:00'), 1,    1],
          [Time.parse('Sep 13 16:07:00'), 0,     2],
          ],
        },
      ].each do |ex|
      example ex[:report].join(' ') do
        result = @report.where(ex[:report])
        expected_result = [*ex[:result]]
        expect(result).to eq(expected_result)
      end
    end
  end
end
