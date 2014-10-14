require 'event'
require 'event/type'

describe Event::Type do
  # event types declared at spec/support/shared_contexts_for_event_type.rb
  $event_type_contexts.each do |event_type_context|
    context event_type_context[:name] do
      include_context event_type_context[:name]

      it 'has common attributes' do
        if type.time_prefix
          expect(type.time_prefix).to be_kind_of Regexp
        end
        expect(type.time_format).to be_kind_of String
        expect(type.fields).to be_kind_of Regexp
      end

      context "#field_names" do
        it "should return all field names" do
          expect(type.field_names.sort).to be === event_type_context[:field_names].sort
        end
      end
    end
  end

  it 'should raise if #field_names have "/"' do
    expect do
      Event::Type.new(
        time_prefix: nil,
        time_format: '%b %d %H:%M:%S',
        fields: /^[a-z]+ +\d+ \d{2}:\d{2}:\d{2} (?<host\/name>[a-z\-.]+) ((?<client>[^\[]+)\[(?<pid>\d+)\]|(?<client>[^:]+)): /i,
        )
    end.to raise_error
  end

end
