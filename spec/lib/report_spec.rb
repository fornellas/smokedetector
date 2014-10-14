require 'report'

describe Report do
  include_context 'syslog type'
  include_context 'parser syslog'

  before(:example) do
    query = Query.new parser_syslog
    @report = Report.new(query)
  end

  context "#where" do
    example 'average pid' do
      report = ['average', 'pid']
      result = @report.where(report)
      expect(result).to eq(['pid' => 17210.0])
    end

    example 'count' do
      pending
    end

    example 'distinct_count pid' do
      pending
    end

    example 'maximum pid' do
      pending
    end
 
    example 'minimum pid' do
      pending
    end

    example 'median pid' do
      pending
    end

    example 'mode pid' do
      pending
    end
 
    example 'sum pid' do
      pending
    end
  end
end
