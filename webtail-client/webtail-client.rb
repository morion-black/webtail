#!/usr/bin/env ruby
require 'net/http'
require "uri"
require "yaml"
require "rubygems"
require "file/tail"

Config = YAML.load_file 'config.yml'

def sendLog(data)
    uri = (URI.parse("http://#{Config['Connect']['server']}:#{Config['Connect']['port']}/logs/#{Config['Connect']['hostname']}"))
    
    puts "Sending PUT #{uri.request_uri} to #{uri.host}:#{uri.port}"
    Net::HTTP.start(uri.host, uri.port) do |http|
        headers = {'Content-Type' => 'text/plain; charset=utf-8'}
        response = http.send_request('PUT', uri.request_uri, data,
headers)
    puts "Response #{response.code} #{response.message}: #{response.body}"
    end
end


threads = []
Config['Logs']['files'].each { |file|
    threads << Thread.new(file) do
        File::Tail::Logfile.open(file, :backward => 10) do |log|
            log.tail { |line|
                puts file
                sendLog(line)
            }
        end
    end    
}

threads.each {|thread| thread.join }