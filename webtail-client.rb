#!/usr/bin/env ruby
require 'net/http'
require "uri"
require "rubygems"
require "file/tail"

def sendLog(data)
    server = "localhost"
    port = "4567"
    hostname = "web20"
    uri = (URI.parse("http://#{server}:#{port}/logs/#{hostname}"))
    
    puts "Sending PUT #{uri.request_uri} to #{uri.host}:#{uri.port}"
    Net::HTTP.start(uri.host, uri.port) do |http|
        headers = {'Content-Type' => 'text/plain; charset=utf-8'}
        response = http.send_request('PUT', uri.request_uri, data,
headers)
    puts "Response #{response.code} #{response.message}: #{response.body}"
    end
end


File::Tail::Logfile.open("/var/log/system.log", :backward => 10) do |log|
    log.tail { |line| 
        puts line
        sendLog(line)
    }
end
