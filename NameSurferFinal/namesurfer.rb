require 'sinatra'
require 'sqlite3'
require 'json'
require 'sinatra/reloader' if development?

configure do
	enable :sessions
end

#configure debug log
require 'logger'
Dir.mkdir('logs') unless File.exist?('logs')
$log = Logger.new('logs/output.log','weekly')

DBNAME = "namedatabase.sqlite" #create database file
#File.delete(DBNAME) if File.exists? DBNAME

#create new database
DB = SQLite3::Database.new( DBNAME )

#create table of names
#DB.execute("CREATE TABLE names(firstname string, y1900 integer, y1910 integer, y1920 integer, y1930 integer, y1940 integer, y1950 integer, y1960 integer, y1970 integer, y1980 integer, y1990 integer, y2000 integer)")

def populateDatabase(filename)
	File.readlines(filename).each do |line|
		firstname, y1900, y1910, y1920, y1930, y1940, y1950, y1960, y1970, y1980, y1990, y2000 = line.split(" ")
		insert_query = "INSERT INTO names(firstname,y1900,y1910,y1920,y1930,y1940,y1950,y1960,y1970,y1980,y1990,y2000) VALUES('#{firstname}','#{y1900}','#{y1910}','#{y1920}','#{y1930}','#{y1940}','#{y1950}','#{y1960}','#{y1970}','#{y1980}','#{y1990}','#{y2000}')" 
		puts("INSERT OF #{firstname} COMPLETE")
		DB.execute(insert_query)
	end
end

def retrieveNameData(firstname)

	#create query to get data for name from database
	select_query = "SELECT * FROM names WHERE firstname = '#{firstname}'"

	#get result from select_query
	results = DB.execute(select_query)

	results.each do |row|
		row = row.to_s
		row = row.gsub("[","").gsub("\"","").gsub(",","").gsub("\\n","").gsub("]","")
		firstname, y1900, y1910, y1920, y1930, y1940, y1950, y1960, y1970, y1980, y1990, y2000 = row.split(" ")	
		return [firstname,y1900,y1920,y1930,y1940,y1950,y1960,y1960,y1970,y1980,y1990,y2000]
	end
	
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

# this is the route I created that the AJAX request will communicate with
get '/name' do
  if params['name']
    
    content_type :json

    result = retrieveNameData(params['name'].to_s)

    result.to_json
  else
    halt(404)
  end
end

