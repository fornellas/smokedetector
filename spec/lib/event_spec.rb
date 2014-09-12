require 'event'
require 'event/type'

describe Event do
  # events declared at spec/support/shared_contexts_for_event.rb
  $event_contexts.each do |event_context|
    context event_context[:name] do
      include_context event_context[:name]
      it 'has common attributes' do
        expect(event.raw).to be_kind_of String
        expect(event.type).to be_kind_of Event::Type
      end
      context '#time' do
        it 'should extract time from raw event' do
          expect(event.time).to eq(event_context[:time])
        end
      end
      context '#[]' do
        it 'should extract fields returned by #field_names' do
          event.type.field_names.each do |field_name|
            expect(event[field_name]).to be_kind_of String
          end
        end
        it 'should extract known fields' do
          event_context[:fields].each do |field_name, field_value|
            expect(event[field_name]).to eq(field_value)
          end
        end
      end
    end
  end
end
