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
  slim(:logout)
end


def connect_to_db(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  return db
 end

def list
 db = SQLite3::Database.new('db/ovning_urval.db')
 db.results_as_hash = true
 result = db.execute("SELECT name FROM Characters")
 return result
end

post('/login') do
  username = params[:username]
  password = params[:password]
  email = params[:email]
  
  db = SQLite3::Database.new('db/ovning_urval.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM user WHERE name = ?", username).first

    puts "Resultat från databasen: #{result}"
    pwdigest = result["password"]
    puts "Pwdigest från databasen: #{pwdigest}" 

    if BCrypt::Password.new(pwdigest) == password
      session[:id] = result["ID"]
      redirect('/home')
    else
      "Fel lösenord"
    end
end

post("/") do
 username = params[:username]
 password = params[:password]
 email= params[:email]
 password_confirm= params[:password_comfirm]

  if (password == password_confirm)
    password_digest= BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/ovning_urval.db')
    db.execute("INSERT INTO user (name,password,email) VALUES(?,?,?)",username,password_digest,email)
    redirect('/')

  else
    "fel lösenord"
    
  end
end