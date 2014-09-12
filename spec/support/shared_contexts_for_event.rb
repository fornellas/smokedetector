require 'time'

require 'event'
require 'event/type'

# Event shared context names
$event_contexts = []

# Add event to $event_contexts
def add_event_context options={}
  event_name = "#{options[:name]} event"
  $event_contexts << {
    name: event_name,
    time: options[:time],
    fields: options[:fields],
    }
  shared_context event_name do
    include_context "#{options[:name]} type"
    let(:event) do
      Event.new(
        raw: options[:raw],
        type: type,
        )
    end
  end
end

add_event_context(
  name: 'syslog',
  raw: 'Sep 11 21:55:01 brown /USR/SBIN/CRON[10912]: (root) CMD (command -v debian-sa1 > /dev/null && debian-sa1 1 1)',
  time: Time.parse('Sep 11 21:55:01'),
  fields: {
    hostname: 'brown',
    client: '/USR/SBIN/CRON',
    pid: '10912',
    }
  )

add_event_context(
  name: 'with time prefix',
  raw: 'time_prefixSep 11 21:55:01 message',
  time: Time.parse('Sep 11 21:55:01'),
  fields: {
    message: 'message',
    }
  )
