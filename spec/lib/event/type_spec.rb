require 'event'
require 'event/type'

describe Event::Type do

  subject do
    described_class.new(
      time_prefix: /^pre-time-text /,
      time_format: '%Y-%m-%d %H:%M:%S',
      time_utc_offset: 3600*3,
      fields: /^pre-time-text [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} (?<field1>[^ ]+) (?<field2>[^ ]+)$/
      )
  end

  its(:time_prefix) { should be_kind_of Regexp }

  its(:time_format) { should be_kind_of String }

  its(:time_utc_offset) { should be_kind_of Integer }

  its(:fields) { should be_kind_of Regexp }

end
