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

shared_context 'parser http' do
  let(:parser_http) do
    Parser.new(
      io: File.open('spec/support/logs/http'),
      event_type: type,
      max_line_length: 1000,
      multi_line: false,
      )
  end
end

shared_context 'parser nginx' do
  let(:parser_nginx) do
    Parser.new(
      io: File.open('spec/support/logs/nginx'),
      event_type: type,
      max_line_length: 1000,
      multi_line: false,
      )
  end
end