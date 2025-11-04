#!/usr/bin/env ruby
require 'webrick'

port = (ENV['PORT'] || 4567).to_i
root = File.expand_path(File.dirname(__FILE__))

server = WEBrick::HTTPServer.new(:Port => port, :DocumentRoot => root)
trap('INT') { server.shutdown }
puts "Serving #{root} on http://localhost:#{port}"
server.start
