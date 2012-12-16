require './lib/db'
require 'rss'
require 'mongrel'

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

class Makerss < Mongrel::HttpHandler
	def initialize
		@db = DB.new
		@column_name = @db.table_info.map {|v| v[1]}
	end

	def process(request, response)
    response.start(200) do |head, out|
      head["Content-Type"] = "text/html"
			out.puts make_rss
    end
	end

	def make_rss
		rss = RSS::Maker.make("2.0") do |maker|
			maker.channel.title = "BoB Security News"
			maker.channel.description = "This page shows latest security news"
			maker.channel.link = "/"
			maker.channel.date = Time.now.to_s
			maker.items.do_sort = true


			articles = @db.select_top 30
			articles.each do |ar|
				article = ar
				article.map!.with_index {|v, k| [@column_name[k],v]}
				article = Hash[article]
				maker.items.new_item do |item|
					item.link = article['link']
					article['category'] = "ETC" if not article['category'] or article['category'].size == 0
					item.title = "[" + article['category'] + "]" + article['title']
					item.description = article['desc']
					item.author = article['author']
					item.date = article['date']
				end
			end
			
		end
	end
end





