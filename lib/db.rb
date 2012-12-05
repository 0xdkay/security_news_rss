require 'sqlite3'

class DB
	def initialize
		begin
			@db_name = "database.db"
			@table_name = "storage"
			@db = SQLite3::Database.new(@db_name)
			@db.execute "
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

			"
		rescue
			#already exists
		end
	end

	def insert args
		#args[3] == title
		@db.execute("INSERT INTO #{@table_name} (site, category, link, title, desc, author, date)
								  SELECT ?, ?, ?, ?, ?, ?, ?
								WHERE NOT EXISTS (SELECT id FROM #{@table_name} WHERE title=?);",
								args+[args[3]])
	end

	def delete id
		@db.execute("DELETE FROM #{@table_name} WHERE id=?;", id)
	end

	def select id
		@db.execute("SELECT id, site, category, link, title, desc, author, date FROM #{@table_name} WHERE id=?;", id)
	end

	def select_all
		@db.execute("SELECT * FROM #{@table_name};")
	end

	def table_info
		@db.execute("PRAGMA table_info(#{@table_name})")
	end

	def size
		@db.execute("SELECT COUNT(*) FROM #{@table_name};")[0][0]
	end
end




