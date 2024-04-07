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

get('/logout') do 
  session.clear
  slim(:home)
end

get('/exercises') do 
  slim(:exercises)
end 

get('/diets') do 
  slim(:diets)
end 

get('/plans') do 
  slim(:plans)
end 

post("/login_form") do
  username = params[:username]
  password = params[:password]
  email = params[:email]
  
  db = SQLite3::Database.new('db/ovning_urval.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM user WHERE name = ?", username).first

  if result && BCrypt::Password.new(result["password"]) == password
    session[:user_id] = result["ID"] # Set the session user_id
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
    slim(:register, locals: { error_message: "Lösenordet Matchar Inte" })
  end
end

post '/save_plans' do
  # Retrieve user input from the form
  monday = params[:monday_input]
  tuesday = params[:tuesday_input]
  wednesday = params[:wednesday_input]
  thursday = params[:thursday_input]
  friday = params[:friday_input]
  saturday = params[:saturday_input]
  sunday = params[:sunday_input]
  
  # Insert the user's plans into the plans table
  db = SQLite3::Database.new('db/ovning_urval.db')
  db.execute("INSERT INTO plans (UserID, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", session[:user_id], monday, tuesday, wednesday, thursday, friday, saturday, sunday)

  redirect '/plans'
end
