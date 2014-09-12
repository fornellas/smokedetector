require 'event'
require 'event/type'

describe Event::Type do
  # event types declared at spec/support/shared_contexts_for_event_type.rb
  $event_type_contexts.each do |event_type_context|
    context event_type_context[:name] do
      include_context event_type_context[:name]
      it 'has common attributes' do
        expect(type.time_prefix).to be_kind_of Regexp
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

end
