require 'mechanize'
require './lib/db'
require 'htmlentities'
# coding : UTF-8

class Getsite
	def initialize(print=nil)
		@print = print
		@insert = true

		@db = DB.new
		@coder = HTMLEntities.new
		get_hackernews
		get_nakedsecurity
		get_securityphresh
		get_esecurity
	end


	private
	def do_print category, link, title, description, author, date
			puts "category: #{category}"
			puts "link: #{link}"
			puts "title: #{title}"
			puts "description: #{description}"
			puts "author: #{author}"
			puts "date: #{date}"
			puts 
	end

	protected
	def get_hackernews
		agent=Mechanize.new
		site="http://www.thehackernews.com"
		page=agent.get site
		page.search("//div[@class='post hentry']").each do |v|

			category=nil
			t=v.search("h3[@class='post-title entry-title']/a")
			link=t.attr('href').text.strip
			title=t.text.strip
			description=v.search("div[@class='post-body entry-content']/div/div").text.strip
			author=v.search("div/span[@class='author']")[0].text.split[2..-1].join(' ').strip
			date=v.search("abbr[@class='updated']").text.strip

			#delete html special characters
			description = @coder.encode(description, :named).split.join(' ')
			date = date.split('/')
			date = [date[1],date[0],date[2]].join('/')

			if @print
				do_print category, link, title, description, author, date
			end

			if @insert
				@db.insert(site, category, link, title, description, author, date)
			end
		end

		puts "Get data from #{site} is done."
	end

	def get_nakedsecurity
		agent = Mechanize.new
		site = "http://nakedsecurity.sophos.com/"
		page = agent.get site
		page.search("//div[starts-with(@id,'post')]").each do |v|

			t=v.search("h2/a")
			title = t.text
			link = t.attr('href').text
			category = nil
			t= v.search("div[@class='entry-meta']")
			description = v.search("div[@class='entry-summary']/p")[0].text
			author = t.search("span[@class='author vcard']").text
			date = t.text.split('on ')[1]
			date = date.split("\t")[0]

			if @print
				do_print category, link, title, description, author, date
			end
			
			if @insert
				@db.insert(site, category, link, title, description, author, date)
			end
		end

		puts "Get data from #{site} is done."
	end

	def get_securityphresh
		agent = Mechanize.new
		site = "http://securityphresh.com/latest-security-news.php"
		page = agent.get site
		page.search("//div[@class='feed_title_row']").each do |v|

			category = nil
			title = v.search("span[@class='feed_title']").text.strip
			date = v.search("span[@class='feed_date']").text.strip
			author = v.search("span[@class='feed_source']/a").text.strip
			description = v.search("span[@class='feed_desc']").text.strip
			link = v.search("div[@style='float:right;font-size:15px;']/a").attr('href').text

			date = date.split
			date = date[1] + " " + date[0].gsub(/[^\d]/,'') + "," + date[2]
			link = CGI::parse(URI.parse(link).query)['sp_url'][0]

			if @print
				do_print category, link, title, description, author, date
			end

			if @insert
				@db.insert(site, category, link, title, description, author, date)
			end
		end

		puts "Get data from #{site} is done."
	end

	def get_esecurity(print=nil)
		agent = Mechanize.new
		site = "http://www.esecurityplanet.com"
		page = agent.get site
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

			if @print
				do_print category, link, title, description, author, date
			end
			
			if @insert
				@db.insert(site, category, site+link, title, description, author, date)
			end
		end

		puts "Get data from #{site} is done."
	end
end







