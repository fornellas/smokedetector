shared_context 'parser syslog' do
  let(:parser_syslog) do
    Parser.new(
      io: File.open('spec/support/logs/syslog'),
      event_type: type,
      max_line_length: 1000,
      multi_line: false,
      )
  end
end
