require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

get('/') do
  slim(:home)
end

get('/home') do 
  slim(:home)
end 

get('/register') do 
  slim(:register)
end 

get('/login') do 
  slim(:login)
end 

get('/logout') do 
  session.clear
  slim(:home)
end

get('/exercises') do 
  slim(:exercises)
end 

post('/login_form') do
  username = params[:username]
  password = params[:password]
  email = params[:email]
  
  db = SQLite3::Database.new('db/ovning_urval.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM user WHERE name = ?", username).first

  if result && BCrypt::Password.new(result["password"]) == password
    session[:name] = result["name"]
    redirect('/home')
  else
    "Incorrect username or password"
  end
end

post("/register_form") do
  username = params[:username]
  password = params[:password]
  email = params[:email]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/ovning_urval.db')
    db.execute("INSERT INTO user (name, password, email) VALUES (?, ?, ?)", username, password_digest, email)
    session[:name] = username
    redirect('/home')
  else
    "Passwords do not match"
  end
end
