require 'sort'

describe Sort do
  let(:sort) do
    Sort.new(
      [
        ['url', '200', '500'],
        ['/b',  1, 2],
        ['/a',  1, 3],
        ]
      )
  end

  context "#by"  do
    [
      {
        sort: ['url'],
        result: [
          ['url', '200', '500'],
          ['/a',  1,     3],
          ['/b',  1,     2],
          ],
        },
      {
        sort: ['-url'],
        result: [
          ['url', '200', '500'],
          ['/b',  1, 2],
          ['/a',  1, 3],
          ],
        },
      {
        sort: ['500'],
        result: [
          ['url', '200', '500'],
          ['/b',  1, 2],
          ['/a',  1, 3],
          ],
        },
      {
        sort: ['-500'],
        result: [
          ['url', '200', '500'],
          ['/a',  1, 3],
          ['/b',  1, 2],
          ],
        },
      ].each do |ex|
      example ex[:sort].join(' ') do
          result = sort.by(ex[:sort])
          expected_result = [*ex[:result]]
          expect(result).to eq(expected_result)
      end
    end
  end
end