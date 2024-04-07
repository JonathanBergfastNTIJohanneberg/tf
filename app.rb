require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

# Establish a single database connection
$db = SQLite3::Database.new('db/ovning_urval.db')
$db.results_as_hash = true

# Helper method to check if user is logged in
def logged_in?
  !session[:user_id].nil? # If session user_id is set, the user is logged in
end

get('/') do
  slim(:home, locals: { logged_in: logged_in? }) # Pass the logged_in status to the view
end

get('/home') do 
  slim(:home, locals: { logged_in: logged_in? })
end

get('/register') do 
  slim(:register, locals: { logged_in: logged_in? })
end 

get('/logout') do 
  session.clear
  redirect('/home')
end

get('/exercises') do 
  slim(:exercises, locals: { logged_in: logged_in? })
end 

get '/diets' do
  # Fetch diets along with user names from the database
  diets = $db.execute("SELECT diets.*, user.name AS user_name FROM diets JOIN user ON diets.UserID = user.ID")
  slim(:diets, locals: { logged_in: logged_in?, diets: diets })
end


get('/plans') do 
  slim(:plans, locals: { logged_in: logged_in? })
end 

post("/login_form") do
  username = params[:username]
  password = params[:password]
  email = params[:email]
  
  result = $db.execute("SELECT * FROM user WHERE name = ?", username).first

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
    $db.execute("INSERT INTO user (name, password, email) VALUES (?, ?, ?)", username, password_digest, email)
    session[:name] = username
    redirect('/home')
  else
    slim(:register, locals: { error_message: "Lösenordet Matchar Inte", logged_in: logged_in? })
  end
end

post '/save_plans' do
  # Check if the user is logged in before saving plans
  if logged_in?
    # Retrieve user input from the form
    monday = params[:monday_input]
    tuesday = params[:tuesday_input]
    wednesday = params[:wednesday_input]
    thursday = params[:thursday_input]
    friday = params[:friday_input]
    saturday = params[:saturday_input]
    sunday = params[:sunday_input]

    # Insert the user's plans into the plans table
    $db.execute("INSERT INTO plans (UserID, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", session[:user_id], monday, tuesday, wednesday, thursday, friday, saturday, sunday)

    redirect '/plans'
  else
    # Handle unauthorized access (e.g., display an error message or redirect to the login page)
    redirect '/home'
  end
end

post '/save_diet' do
  # Check if the user is logged in before saving diets
  if logged_in?
    # Retrieve user input from the form
    diet_name = params[:diet_name_input]
    diet_info = params[:diet_info_input]
    name = params[:name_input]

    # Retrieve the user ID from the session
    user_id = session[:user_id]

    # Insert the user's diet into the diets table
    $db.execute("INSERT INTO diets (Diet_Name, Diet_Info, UserID, name) VALUES (?, ?, ?, ?)", diet_name, diet_info, user_id, name)

    redirect '/diets'
  else
    # Handle unauthorized access (e.g., display an error message or redirect to the login page)
    redirect '/home'
  end
end
