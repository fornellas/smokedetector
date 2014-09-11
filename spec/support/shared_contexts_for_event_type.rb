require 'event'
require 'event/type'

shared_context "syslog" do
  let(:type) do
    Event::Type.new(
      time_prefix: //,
      time_format: '%Y-%m-%d %H:%M:%S',
      fields: /^[a-z]+ +\d+ \d{2}:\d{2}:\d{2} (?<hostname>[a-z\-.]+) ((?<client>[^\[]+)\[(?<pid>\d+)\]|(?<client>[^:]+)): /i,
      )
  end
end

shared_context "with time prefix" do
  let(:type) do
    Event::Type.new(
      time_prefix: /^time_prefix/,
      time_format: '%Y-%m-%d %H:%M:%S',
      fields: /^time_prefix[a-z]+ +\d+ \d{2}:\d{2}:\d{2} (?<message>.+)/i,
      )
  end
end
