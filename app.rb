require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions


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



get('/showlogin') do
  slim(:login)
end



post('/login') do
  username = params[:username]
  password = params[:password]
  email = params[:email]
  db = SQLite3::Database.new('db/ovning_urval.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE user_name =? OR user_mail=? ",username,email).first
  pwdigest= result["user_pwd"]
  id= result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/todos')
  else
    "fel lösenord"
  end


end


get('/') do
  slim(:register)
end


get('/todos') do 
  id = session[:id].to_i
  db = SQLite3::Database.new('db/ovning_urval.db')
  db.results_as_hash = true
  result = db.execute("SELECT name FROM Characters")
  p   "alla todos från result #{result}"
  slim(:"todos/index", locals:{todos:result})
end


get('/showlogout') do 
    slim(:logout)
end

post("/users/new") do
 username = params[:username]
 password = params[:password]
 email= params[:email]
 password_confirm= params[:password_comfirm]

  if (password == password_confirm)
    password_digest= BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/ovning_urval.db')
    db.execute("INSERT INTO users (user_name,user_pwd,user_mail) VALUES(?,?,?)",username,password_digest,email)
    redirect('/')

  else
    "fel lösenord"
    
  end
end