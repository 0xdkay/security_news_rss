require 'mechanize'
require './db'

=begin
 1. You have to construct your own parsing mechanism depending on each site.
 2. Please match the format of database so that we can combine data easily.
	(you can see db.insert part)
=end

class Getsite
	def initialize
		@db = DB.new
	end


	def get_esecurity PRINT=nil
		agent = Mechanize.new
		page = agent.get "http://www.esecurityplanet.com"
		site = "http://www.esecurityplanet.com"
		page.search("//div[@class='article homepage']").each do |v|
			category = v.search("div[@class='category']/p").text.strip

			t = v.search("h2/a")
			if not t.empty?
				description = v.search("p")[1].text
			else 
				t = v.search("div/h3/a")
				description = v.search('p')[2].text
			end

			link = t.attr('href').text
			title = t.text
			author = v.search("a[@class='home']").text
			date = v.search("span[@class='publish-date']").text.strip

			if PRINT
				puts "category: #{category}"
				puts "link: #{link}"
				puts "title: #{title}"
				puts "description: #{description}"
				puts "author: #{author}"
				puts "date: #{date}"
				puts 
			end
			
			@db.insert(site, category, link, title, description, author, date)
		end
	end
end







