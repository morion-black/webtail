#!/usr/bin/env ruby
require "net/http"
require "uri"
require "yaml"
require "rubygems"
require "file/tail"

puts "Configfile (config.yml) not found" unless File.readable?('config.yml')

begin
	CONFIG = YAML.load_file('config.yml')
rescue Exception => errmsg
	puts "Configfile format error: #{errmsg}"
end

def sendLog(data)
    uri = (URI.parse("http://#{CONFIG['Connect']['server']}:#{CONFIG['Connect']['port']}/logs/#{CONFIG['Connect']['hostname']}"))
    
    puts "Sending PUT #{uri.request_uri} to #{uri.host}:#{uri.port}"
    Net::HTTP.start(uri.host, uri.port) do |http|
        headers = {'Content-Type' => 'text/plain; charset=utf-8'}
        response = http.send_request('PUT', uri.request_uri, data, headers)
    puts "Response #{response.code} #{response.message}: #{response.body}"
    end
end


threads = []
CONFIG['Logs']['files'].each { |file|
    threads << Thread.new do
        File::Tail::Logfile.open(file, :backward => 10) do |log|
            log.tail { |line|
                puts file
                sendLog(line)
            }
        end
    end    
}

threads.each {|thread| thread.join }