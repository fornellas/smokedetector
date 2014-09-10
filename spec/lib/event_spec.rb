require 'event'
require 'event/type'

describe Event do

  its(:raw) { should be_kind_of String }

  its(:type) { should be_kind_of Event::Type }

  context '#time' do
    # different time_prefix
    # different time_format
    # different time_zone
  end

  context '#field_names' do
    # return all field names
  end

  context '#[]' do
    # should extract fields
  end

end
