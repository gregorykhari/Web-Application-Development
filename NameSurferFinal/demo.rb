require 'fileutils'
include FileUtils::Verbose
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'CSV'
require 'stringio'
require 'bcrypt'
require 'zip/zip'
require 'erb'

configure do
  enable :sessions
  set :admin_username, 'admin'
  set :admin_password, BCrypt::Password.new("$2a$10$WACxlT8HNX5MWkyLX9xNrO96CtmB49kXKfgJ6dr1xn4NTcp7dW5lm")
end

#configure debug log
require 'logger'
Dir.mkdir('logs') unless File.exist?('logs')
$log = Logger.new('logs/output.log','weekly')

DBNAME = "techlounge.sqlite"
DB = SQLite3::Database.new(DBNAME)

DB.execute("CREATE TABLE employees(employeeID string, firstname string, lastname string, password string)")

get '/' do 
  send_file File.join(settings.public_folder, 'index.html')
end

get '/admin' do
  send_file File.join(settings.public_folder, 'admin.html')
end

post '/admin'
  
end

def createNewEmployee(employeeID, firstname, lastname, password)

  select_query = "FROM employees * WITH employeeID == #{employeeID}"

  #execute select_query to check if an employee with the same employeeID exists already
  result = DB.execute(select_query)

  if result != []
    return false
  end
  
  #create new hashed password 
  password = BCrypt::Password.create("#{password}")

  #insert query to add new employee to database
  insert_query = "INSERT INTO employees(employeeID, firstname, lastname,password) VALUES('#{employeeID}','#{firstname}','#{lastname}','#{password}')"

  #execute insert_query
  DB.execute(insert_query)

  return true
end