require 'event'
require 'event/type'

describe Event::Type do

  context 'syslog' do
    include_context 'syslog'
    it_behaves_like 'any event type'
  end

  context 'with time prefix' do
    include_context 'with time prefix'
    it_behaves_like 'any event type'
  end

end
