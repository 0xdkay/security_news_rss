require './db'
require 'rss'

# Database format is shown as below:
=begin
	CREATE TABLE #{@table_name} (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		site varchar(30),
		category varchar(50),
		link text,
		title text,
		desc text,
		author varchar(50),
		date varchar(50)
	);

["id", "site", "category", "link", "title", "desc", "author", "date"]
=end

class Makerss
	def initialize
		@db = DB.new
		db = DB.new
		column_name = db.table_info.map {|v| v[1]}
		rss = RSS::Maker.make("2.0") do |maker|
			maker.channel.title = "BoB Security News"
			maker.channel.description = "This page shows latest security news"
			maker.channel.link = "http://gon.kaist.ac.kr"
			maker.channel.date = Time.now.to_s
			maker.items.do_sort = true

			#TODO: select latest news
			db.size.times do |i|
				article = db.select(i+1)[0]
				article.map!.with_index {|v, k| [column_name[k],v]}
				article = Hash[article]
				maker.items.new_item do |item|
					item.link = article['site'] + article['link']
					item.title = article['title']
					item.description = article['desc']
					item.author = article['author']
					item.date = article['date']
				end
			nd

			#TODO: add this to server
			open("/var/www/test/rss.html", "w"){|f| f.puts rss}
		end
	end
end





