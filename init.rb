require 'rubygems'
require 'mongrel'
require 'thread'
require './lib/rss'
require './lib/get_site'

host    = ARGV[0] || "127.0.0.1"
port    = ARGV[1] || 80
docroot = ARGV[2] || "html/"

# Configure Mongrel and handlers
config = Mongrel::Configurator.new :host => host, :port => port do
	listener do
		redirect("/", "/rss")
		uri "/",              :handler => Mongrel::DirHandler.new(docroot)
		uri "/rss", 					:handler => Makerss.new, :in_front => true
	end

	# CTRL+C to stop server
	trap("INT") do
		puts "server is going down..."
		$server_on = false
		stop
	end
	run
end

# Start Mongrel
puts "Mongrel listening on '#{host}:#{port}', serving documents from '#{docroot}'."

get = Getsite.new 1
get.crawl

t = Thread.new do
	$server_on = true
	start = Time.now
	while $server_on do
		if Time.now - start >= 3600
			get.crawl
			start = Time.now
		end
		sleep(10)
	end
end

config.join
t.join



