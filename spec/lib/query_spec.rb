require 'query'

require 'event/type'
require 'parser'

describe Query do

  include_context 'syslog type'
  include_context 'parser syslog'

  before(:example) do
    @filter = Query.new parser_syslog
  end

  context '#each' do
    xit 'should yield each filtered event to given block' do
    end
  end

  shared_examples 'where | not' do
    xit 'should return self' do
    end

    xit 'should return extra arguments' do
    end

    context 'time' do
      it 'from [DATE]' do
        query = ['from', 'Sep 13 16:11:54']
        count = @filter.send(method, *query).count
        expect(count).to eq(3) if method == :where
        expect(count).to eq(2) if method == :not
      end

      it 'to [DATE]' do
        query = ['to', 'Sep 13 16:11:54']
        count = @filter.send(method, *query).count
        expect(count).to eq(3) if method == :where
        expect(count).to eq(2) if method == :not
      end
    end

    context 'field' do
      it 'field [NAME] matches [REGEXP]' do
        query = ['field', 'pid', 'matches', '55']
        count = @filter.send(method, *query).count
        expect(count).to eq(2) if method == :where
        expect(count).to eq(3) if method == :not
      end

      xit 'field [NAME] min [VALUE]' do
      end

      xit 'field [NAME] max [VALUE]' do
      end
    end
    context 'slice' do
      xit 'first [COUNT]' do
      end

      xit 'skip [COUNT]' do
      end

      xit 'percent [VALUE]' do
      end
    end
  end

  context '#where' do
    let(:method){ :where }
    include_examples 'where | not'
  end

  context '#not' do
    let(:method){ :not }
    include_examples 'where | not'
  end

end
