require 'query'

require 'event/type'
require 'parser'

describe Query do

  include_context 'syslog type'
  include_context 'parser syslog'

  let(:query) do
    Query.new parser_syslog
  end

  context '#each' do
    it 'should yield each filtered event to given block' do
      event_count = 0
      query.each do |event|
        event_count += 1
      end
      expect(event_count).to eq(5)
    end
  end

  context '#where' do
    it 'should return self' do
      expect(query.where([])).to eq(query)
    end

    it 'should consume known arguments from filters' do
      filter = ['from', 'Sep 13 16:11:54', 'a', 'b']
      query.where(filter)
      expect(filter).to eq(['a', 'b'])
    end

    it 'should accept multiple filters an process them as an AND' do
      filter = ['from', 'Sep 13 16:11:53', 'to', 'Sep 13 16:15:01']
      event_count = query.where(filter).count
      expect(event_count).to eq(3)
    end

    [
      {
        filter: ['from', 'Sep 13 16:11:54'],
        expected_count: 3,
        },
      {
        filter: ['to', 'Sep 13 16:11:54'],
        expected_count: 3,
        },
      {
        filter: ['field', 'pid', 'matches', '55'],
        expected_count: 2,
        },
      {
        filter: ['field', 'pid', 'min', '20000'],
        expected_count: 3,
        },
      {
        filter: ['field', 'pid', 'max', '20000'],
        expected_count: 2,
        },
=begin
      {
        filter: ['first', '2'],
        expected_count: 2,
        },
      {
        filter: skip [COUNT],
        expected_count: ,
        },
=end
      ].each do |ex|

      example ex[:filter].join(' ') do
        event_count = query.where(ex[:filter].dup).count
        expect(event_count).to eq(ex[:expected_count])
      end

      example "not " + ex[:filter].join(' ') do
        event_count = query.where(['not'] + ex[:filter].dup).count
        expect(event_count).to eq(5-ex[:expected_count])
      end

    end

    example 'percent 0' do
      allow(Random).to receive(:rand).and_return(1)
      filter = ['percent', '0']
      event_count = query.where(filter).count
      expect(event_count).to eq(0)
    end

  end

end
