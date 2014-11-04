require 'query'

require 'event/type'
require 'parser'

describe Query do

  include_context 'syslog type'
  include_context 'parser syslog'

  before(:example) do
    @query = Query.new parser_syslog
  end

  context '#each' do
    it 'should yield each filtered event to given block' do
      event_count = 0
      @query.each do |event|
        event_count += 1
      end
      expect(event_count).to eq(5)
    end
  end

  context '#where' do
    it 'should return self' do
      expect(@query.where([])).to eq(@query)
    end

    it 'should consume known arguments from filters' do
      query = ['from', 'Sep 13 16:11:54', 'a', 'b']
      @query.where(query)
      expect(query).to eq(['a', 'b'])
    end

    it 'should accept multiple filters an process them as an AND' do
      query = ['from', 'Sep 13 16:11:53', 'to', 'Sep 13 16:15:01']
      event_count = @query.where(query).count
      expect(event_count).to eq(3)
    end

    [
      {
        query: ['from', 'Sep 13 16:11:54'],
        expected_count: 3,
        },
      {
        query: ['to', 'Sep 13 16:11:54'],
        expected_count: 3,
        },
      {
        query: ['field', 'pid', 'matches', '55'],
        expected_count: 2,
        },
      {
        query: ['field', 'pid', 'min', '20000'],
        expected_count: 3,
        },
      {
        query: ['field', 'pid', 'max', '20000'],
        expected_count: 2,
        },
=begin
      {
        query: ['first', '2'],
        expected_count: 2,
        },
      {
        query: skip [COUNT],
        expected_count: ,
        },
=end
      ].each do |ex|

      example ex[:query].join(' ') do
        event_count = @query.where(ex[:query].dup).count
        expect(event_count).to eq(ex[:expected_count])
      end

      example "not " + ex[:query].join(' ') do
        event_count = @query.where(['not'] + ex[:query].dup).count
        expect(event_count).to eq(5-ex[:expected_count])
      end

    end

    example 'percent 0' do
      allow(Random).to receive(:rand).and_return(1)
      query = ['percent', '0']
      event_count = @query.where(query).count
      expect(event_count).to eq(0)
    end

  end

end
