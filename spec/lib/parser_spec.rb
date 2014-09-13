require 'event'
require 'event/type'
require 'parser'

describe Parser do
  context '#each' do

    include_context 'syslog type'

    let(:parser_syslog) do
      Parser.new(
        io: File.open('spec/support/logs/syslog'),
        event_type: type,
        max_line_length: 1000,
        multi_line: false,
        )
    end

    it 'should throw exception if a line is longer than #max_line_lenght' do
      expect do
        parser_syslog.max_line_length = 1
        parser_syslog.each {|e| e}
      end.to raise_error
    end

    it 'should not throw exception if a line is not longer than #max_line_lenght' do
      expect do
        parser_syslog.max_line_length = 8192
        parser_syslog.each {|e| e}
      end.not_to raise_error
    end

    context 'single line events' do
      it 'should be able to extract events' do
        event_count = 0
        parser_syslog.max_line_length = 8192
        parser_syslog.each do |event|
          event_file = "spec/support/events/syslog.#{event_count}"
          if File.open(event_file).read != event.raw
            raise "Event #raw does not match contents of '#{event_file}': '#{event.raw}'."
          end
          event_count += 1
        end
        if 5 != event_count
          raise "Did not parse all events from #{spec/support/logs/syslog}."
        end
      end
    end

    context 'multi line events' do
      let(:parser_multi_line) do
        Parser.new(
          io: File.open('spec/support/logs/multi_line'),
          event_type: type,
          max_line_length: 2048,
          multi_line: true,
          multi_line_start: /^[a-z]+ +\d+ \d{2}:\d{2}:\d{2} /i,
          multi_line_max: 1000,
          )
      end
  
      it 'should extract events starting at lines matching #multi_line_start' do
        parser_multi_line.multi_line_max = 1000
        event_count = 0
        parser_multi_line.each do |event|
          event_file = "spec/support/events/multi_line.#{event_count}"
          if File.open(event_file).read != event.raw
            raise "Event #raw does not match contents of '#{event_file}': '#{event.raw}'"
          end
          event_count += 1
        end
      end

      it 'should throw exception if event has more than #multi_line_max' do
        parser_multi_line.multi_line_max = 2
        expect do
          parser_multi_line.each {|event| }
        end.to raise_error
      end
    end
  end
end
