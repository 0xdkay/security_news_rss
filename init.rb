require 'rubygems'
require 'mongrel'
require './lib/rss'

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
	trap("INT") { stop }
	run
end

# Start Mongrel
puts "Mongrel listening on '#{host}:#{port}', serving documents from '#{docroot}'."
config.join



