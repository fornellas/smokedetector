#!/home/fornellas/local/ruby21/bin/ruby

require 'pp'
require_relative 'event'
require_relative 'extractor'

clients = Hash.new
Extractor.new(
  strptime: '%b %d %H:%M:%S',
  field_extraction: /^[a-z]+ +\d+ \d{2}:\d{2}:\d{2} (?<hostname>[a-z\-.]+) ((?<client>[^\[]+)\[(?<pid>\d+)\]|(?<client>[^:]+)): /i,
  ).each do |event|
  puts event.raw
  puts event.time
  client = event['client']
  clients[client] ||= 0
  clients[client] += 1
  event.fields.each do |field|
    puts "#{field}: #{event[field]}"
  end
  puts ''
end

pp clients
