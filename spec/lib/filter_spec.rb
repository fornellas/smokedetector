require 'filter'

require 'event/type'
require 'parser'

describe Filter do

  include_context 'syslog type'
  include_context 'parser syslog'

  let(:filter) do
    Filter.new parser_syslog
  end

  context '#where' do

    xit 'should filter by time range' do
    end

    it 'should filter by field value matching regexp' do
      events = []
      field = :client
      regexp = /^dbus$/
      filter.where( field => regexp ) do |event|
        events << event
      end
      expect(events.size).to eq(2)
      events.each do |event|
        expect(event[field]).to match(regexp)
      end
    end

    xit 'should filter by field value numeric range' do
      
    end

  end

end
