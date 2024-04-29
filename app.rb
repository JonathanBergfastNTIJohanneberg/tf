require 'sinatra' # Import the Sinatra framework.
require 'slim' # Import the Slim template engine.
require 'sqlite3' # Import SQLite3 for database interaction.
require 'bcrypt' # Import bcrypt for password hashing.
require 'sinatra/reloader' # Enable reloading of Sinatra app during development.
require 'sinatra/flash' # Enable flashing messages in Sinatra.
require_relative 'models.rb'

enable :sessions # Enable session management.

include Models

# Establish a single database connection.
$db = SQLite3::Database.new('db/ovning_urval.db')
$db.results_as_hash = true # Retrieve results as a hash.

# Helper method to check if user is logged in.
def logged_in?
  !session[:user_id].nil? # Check if session user_id is set.
end

helpers do
  def admin_logged_in?
    !session[:user_id].nil? && $db.execute("SELECT admin FROM user WHERE ID = ?", session[:user_id]).first["admin"] == 1
  end
end


get('/') do
  slim(:"home/home", locals: { logged_in: logged_in? }) # Pass the logged_in status to the view
end

get('/home') do 
  # Render home page, passing logged_in status to template
  slim(:"home/home", locals: { logged_in: logged_in? })
end


get('/register') do 
  # Render registration page, passing logged_in status to template
  slim(:"register/register", locals: { logged_in: logged_in? })
end 

get('/logout') do 
  # Clear session data and redirect to home page
  session.clear
  redirect('/home')
end

get('/exercises') do
  # Render exercises page, passing logged_in status to template
  slim(:"exercises/exercises", locals: { logged_in: logged_in? })
end 


get '/admin' do
  # Retrieve all users from the database
  users = get_users 
  slim(:"admin/index", locals: { users: users })
end

get '/admin/edit' do
  # Retrieve all users from the database
  users = get_users 
  slim(:"admin/edit", locals: { users: users })
end

get '/diets' do
  # Fetch diets along with user names from the database
  diets = get_diets
  slim(:"diets/index", locals: { logged_in: logged_in?, diets: diets})
end

get '/diets/new' do 
  diets = get_diets
  slim(:"diets/new", locals: {logged_in: logged_in?, diets: diets})
end 

get '/diets/show' do 
  diets = get_diets
  slim(:"diets/show", locals: {logged_in: logged_in?, diets: diets})
end 

get '/diets/:id/edit' do 
  diet = get_diet(params[:id])
  slim(:"diets/edit", locals: {logged_in: logged_in?, diet: diet})
end

get '/plans' do
  # Check if the user is logged in
  if logged_in?
    # Retrieve the user's plan by user ID
    user_id = session[:user_id]
    plan = get_user_plan(user_id)
    p plan 
    slim(:"plans/index", locals: { logged_in: logged_in?, plan: plan })
  else
    # Handle unauthorized access
    redirect '/home'
  end
end

get '/plans/show' do 
  user_id = session[:user_id]
  plan = get_user_plan(user_id)
  slim(:"plans/show", locals: { logged_in: logged_in?, plan: plan })
end 


# Metod för att kontrollera om användaren är inloggad och har tillgång till begränsade sidor
def require_login!
  redirect '/register' unless logged_in?
end

# Begränsade sidor som kräver inloggning
restricted_pages = ['/plans', '/diets', '/exercises']

# Använd en "before" -filtret för att köra "require_login!"-metoden före varje route för begränsade sidor
before restricted_pages do
  require_login!
end

post"/login" do
  # Extract username and password from request parameters
  username = params[:username]
  password = params[:password]

  # Query the database for the user with the provided username
  result = get_results(username)

  # Check if user exists and password matches
  if result && BCrypt::Password.new(result["password"]) == password
    # Set session user_id and name if login successful
    session[:user_id] = result["ID"]
    session[:name] = result["name"]
    redirect('/home') # Redirect to home page after successful login
  else
    "Incorrect username or password" # Display error message if login fails
  end
end




post "/create_user" do
  # Extract parameters from request
  username = params[:username]
  password = params[:password]
  email = params[:email]
  password_confirm = params[:password_confirm]

  # Check if password and password confirmation match
  if password == password_confirm
    # Create password digest using bcrypt
    password_digest = BCrypt::Password.create(password)
    
    # Insert new user into the database
    get_register_form(username, password_digest, email)
    
    # Set session name to the registered username
    session[:name] = username
    
    # Redirect to home page after successful registration
    redirect('/home')
  else
    # Render registration page with error message if passwords do not match
    slim(:register, locals: { error_message: "Passwords do not match", logged_in: logged_in? })
  end
end

post '/plans' do
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
    save_plans(session[:user_id], monday, tuesday, wednesday, thursday, friday, saturday, sunday)

    redirect '/plans/show' # Redirect to show page after saving plans
  else
    # Handle unauthorized access (e.g., display an error message or redirect to the login page)
    redirect '/home'
  end
end



post '/diet' do
  # Check if the user is logged in before saving diets
  if logged_in?
    # Retrieve user input from the form
    diet_name = params[:diet_name_input]
    diet_info = params[:diet_info_input]
    name = params[:name_input]

    # Retrieve the user ID from the session
    user_id = session[:user_id]

    # Insert the user's diet into the diets table
    save_diet(diet_name, diet_info, user_id, name)

    redirect '/diets/index'
  else
    # Handle unauthorized access (e.g., display an error message or redirect to the login page)
    redirect '/home'
  end
end

post '/diet/:id/delete' do
  # Check if any user is logged in
  if logged_in?
    # Extract diet ID from request parameters
    diet_id = params[:id]

    # Delete the diet card from the database
    delete_diet(diet_id)

    # Redirect to diets page after deletion
    redirect '/diets'
  else
    # Redirect to home page if no user is logged in 
    redirect '/home'
  end
end


post '/diet/:id/update' do
  require_login!
  
  # Extract parameters from request
  diet_id = params[:id]
  diet = get_diet(diet_id)

  # Verify the logged-in user is the diet owner
  if session[:user_id] == diet['UserID']
    diet_name = params[:diet_name_input]
    diet_info = params[:diet_info_input]
    name = params[:name_input]

    update_diet(diet_name, diet_info, name, diet_id)
    redirect '/diets/show'
  else
    status 403
    "You do not have permission to update this diet."
  end
end



post '/diet/:id/delete' do
  #Ensure the user is logged in
  require_login!
  
  #Extract diet ID from request parameters
  diet_id = params[:id]
  
  #Fetch the diet to check the owner
  diet = get_diet(diet_id)

  #Only proceed if the logged-in user is the owner of the diet
  if session[:user_id] == diet['UserID']
    delete_diet(diet_id)
    redirect '/diets'
  else
    status 403  #Forbidden access
    "You do not have permission to delete this diet."
  end
end


post '/user/:id/update' do
  # Check if admin is logged in
  if admin_logged_in?
    # Extract parameters from request
    user_id = params[:id]
    name = params[:name_user]
    admin = params[:admin]

    # Ensure name parameter is not nil and not empty
    if name && !name.empty?
      # Strip leading and trailing whitespace
      name.strip!
    else
      # Redirect back to admin panel if name is missing or empty
      redirect '/admin'
    end

    # Update the user in the database
    update_user(name, admin, user_id)

    # Redirect to admin panel after update
    redirect '/admin'
  else
    # Redirect to home page if admin is not logged in
    redirect '/home'
  end
end