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
    xit 'should yield each filtered event to given block' do
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
=begin
      {
        query: field [NAME] min [VALUE],
        expected_count: ,
        },
      {
        query: field [NAME] max [VALUE],
        expected_count: ,
        },
      {
        query: first [COUNT],
        expected_count: ,
        },
      {
        query: skip [COUNT],
        expected_count: ,
        },
      {
        query: percent [VALUE],
        expected_count: ,
        },

      {
        query: ,
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

  end

end
