require 'event'
require 'event/type'

# Event::Type shared context names
$event_type_contexts = []

# Add one more shared context to $event_type_contexts
def add_event_type_context options={}, &block
  context_name = "#{options[:name]} type"
  $event_type_contexts << {
    name: context_name,
    field_names: options[:field_names],
    }
  shared_context context_name, &block
end

add_event_type_context({
  name: 'syslog',
  field_names: ['hostname', 'client', 'pid'],
  }) do
  let(:type) do
    Event::Type.new(
      time_prefix: nil,
      time_format: '%b %d %H:%M:%S',
      fields: /^[a-z]+ +\d+ \d{2}:\d{2}:\d{2} (?<hostname>[a-z\-.]+) ((?<client>[^\[]+)\[(?<pid>\d+)\]|(?<client>[^:]+)): /i,
      )
  end
end

add_event_type_context({
  name: 'with time prefix',
  field_names: ['message'],
  }) do
  let(:type) do
    Event::Type.new(
      time_prefix: /^time_prefix/,
      time_format: '%Y-%m-%d %H:%M:%S',
      fields: /^time_prefix\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} (?<message>.+)/i,
      )
  end
end

add_event_type_context({
  name: 'http',
  field_names: ['url', 'status', 'response_time'],
  }) do
  let(:type) do
    Event::Type.new(
      time_prefix: nil,
      time_format: '%b %d %H:%M:%S',
      fields: /^[a-z]+ +\d+ \d{2}:\d{2}:\d{2} (?<url>[^ ]+) (?<status>[^ ]+) (?<response_time>.+)/i,
      )
  end
end

add_event_type_context({
  name: 'nginx',
  field_names: ["remote_addr", "remote_user", "day_of_month", "month_name", "year", "hour", "minute", "second", "timezone", "request_method", "request_uri", "http_version", "request", "status", "body_bytes_sent", "http_referer", "http_user_agent"], }) do
  let(:type) do
    Event::Type.new(
      time_prefix: /^([^ ]+) - ([^ ]+) \[/,
      time_format: '%d/%b/%Y:%H:%M:%S %Z',
      fields: /^(?<remote_addr>[^ ]+) - (?<remote_user>[^ ]+) \[(?<day_of_month>[0-9]+)\/(?<month_name>[^\/]+)\/(?<year>[0-9]+):(?<hour>[0-9]+):(?<minute>[0-9]+):(?<second>[0-9]+) (?<timezone>[^ ]+)\] "((?<request_method>[^ ]+) (?<request_uri>[^ ]+) (?<http_version>[^ ]+)|(?<request>[^"]+))" (?<status>[0-9]+) (?<body_bytes_sent>[0-9]+) "(?<http_referer>[^"]+)" "(?<http_user_agent>[^"]+)"$/,
      )
  end
end
