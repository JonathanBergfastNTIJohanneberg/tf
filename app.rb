require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative 'models.rb'

enable :sessions
include Models

# Initialize database connection
$db = SQLite3::Database.new('db/ovning_urval.db')
$db.results_as_hash = true

# Check if user is logged in
#
# @return [Boolean] True if user is logged in, false otherwise
def logged_in?
  !session[:user_id].nil?
end

helpers do
  # Check if the current user is an admin
  #
  # @return [Boolean] True if user is an admin, false otherwise
  def admin_logged_in?
    logged_in? && user_is_admin?(session[:user_id])
  end

  # Count likes for a specific diet
  #
  # @param [Integer] diet_id ID of the diet
  # @return [Integer] Number of likes
  def count_likes(diet_id)
    Models.count_likes(diet_id)
  end

  # Redirect to login page if user is not logged in
  def require_login!
    redirect '/register' unless logged_in?
  end
end

# Middleware for routes requiring user login
before do
  pass if ['/', '/register', '/login', '/create_user'].include?(request.path_info)
  if session[:user_id].nil?
    session[:error] = "You must be logged in to access this page."
    redirect('/register')
    pass
  end
  if session[:cooldown] && Time.now < session[:cooldown]
    remaining_seconds = (session[:cooldown] - Time.now).ceil
    flash[:error] = "Please wait #{remaining_seconds} seconds before trying again."
    redirect '/register' unless request.path_info == '/register'
  end
end

# Middleware for routes requiring admin privileges
before ['/admin/*'] do
  unless admin_logged_in?
    session[:error] = "You must be an admin to access this page."
    redirect('/home')
  end
end

# Middleware for routes related to plans and diets that require login
before ['/plans/*', '/diets/*'] do
  require_login!
end

# Route to handle plan and diet modification authorization
before ['/diet/:id/update', '/diet/:id/delete'] do
  diet = get_diet(params[:id])
  unless session[:user_id] == diet['UserID']
    status 403
    halt "You do not have permission to modify this diet."
  end
end

# Display the home page
#
# @see Model#get_user_plan
get '/' do
  slim(:'home/home', locals: { logged_in: logged_in? })
end

# Display the home page (alternative route)
#
# @see Model#get_user_plan
get '/home' do
  puts "Current user ID in session: #{session[:user_id]}"
  slim(:'home/home', locals: { logged_in: logged_in? })
end

# Display the registration page, potentially with cooldown timing
#
# @see Model#register_user
get '/register' do
  remaining_seconds = session[:cooldown] && Time.now < session[:cooldown] ? (session[:cooldown] - Time.now).ceil : nil
  slim(:'register/register', locals: { logged_in: logged_in?, remaining_seconds: remaining_seconds })
end

# Logout the current user and redirect to home
#
get '/logout' do
  session.clear
  redirect '/home'
end

# Display admin panel
#
# @see Model#get_users
get '/admin' do
  users = get_users
  slim(:'admin/index', locals: { users: users })
end

# Display admin edit page
#
# @see Model#get_users
get '/admin/edit' do
  users = get_users
  slim(:'admin/edit', locals: { users: users })
end

# Display all diets
#
# @see Model#get_diets
get '/diets' do
  diets = get_diets
  slim(:'diets/index', locals: { logged_in: logged_in?, diets: diets})
end

# Display new diet form
#
# @see Model#get_diets
get '/diets/new' do
  diets = get_diets
  slim(:'diets/new', locals: {logged_in: logged_in?, diets: diets})
end

# Display diet details
#
# @see Model#get_diets
get '/diets/show' do
  diets = get_diets
  slim(:'diets/show', locals: {logged_in: logged_in?, diets: diets})
end

# Display diet edit form
#
# @see Model#get_diet
get '/diets/:id/edit' do
  diet = get_diet(params[:id])
  slim(:'diets/edit', locals: {logged_in: logged_in?, diet: diet})
end

# Display plan edit form
#
# @see Model#get_user_plan_by_id
get '/plans/:id/edit' do
  require_login!
  plan = get_user_plan_by_id(params[:id])
  if plan && session[:user_id] == plan['UserID']
    slim(:'plans/edit', locals: { plan: plan, logged_in: logged_in? })
  else
    flash[:error] = "You are not authorized to edit this plan."
    redirect '/plans'
  end
end

# Display plans index
#
# @see Model#get_user_plan
get '/plans' do
  user_id = session[:user_id]
  plan = get_user_plan(user_id)
  slim(:'plans/index', locals: { logged_in: logged_in?, plan: plan })
end

# Display plans show
#
# @see Model#get_user_plan
get '/plans/show' do
  user_id = session[:user_id]
  plans = get_user_plan(user_id)
  slim(:'plans/show', locals: { logged_in: logged_in?, plans: plans })
end

# Display plans index
#
# @see Model#get_user_plan
get '/plans/index' do
  user_id = session[:user_id]
  plans = get_user_plan(user_id)
  slim(:'plans/index', locals: { logged_in: logged_in?, plans: plans })
end

# Display new plan form
#
# @see Model#get_user_plan
get '/plans/new' do
  user_id = session[:user_id]
  plans = get_user_plan(user_id)
  slim(:'plans/new', locals: { logged_in: logged_in?, plans: plans })
end

# Process login
#
# @see Model#get_results
post '/login' do
  username = params[:username]
  password = params[:password]
  user = get_results(username)

  if user
    if BCrypt::Password.new(user["password"]) == password
      session[:user_id] = user["ID"]
      session[:name] = user["name"]
      session[:attempts] = nil
      session[:cooldown] = nil
      redirect '/home'
    else
      session[:attempts] ||= 0
      session[:attempts] += 1

      if session[:attempts] >= 3
        session[:cooldown] = Time.now + 5
        session[:attempts] = nil
        flash[:error] = "You have used all attempts. Please wait 5 seconds."
      else
        flash[:error] = "Incorrect password. #{3 - session[:attempts]} attempts left."
      end
      redirect back
    end
  else
    flash[:error] = "User not found."
    redirect back
  end
end

# Process user creation
#
# @see Model#get_register_form
post "/create_user" do
  username = params[:username]
  password = params[:password]
  email = params[:email]
  password_confirm = params[:password_confirm]
  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    get_register_form(username, password_digest, email)
    session[:name] = username
    redirect('/home')
  else
    slim(:'register/register', locals: { error_message: "Passwords do not match", logged_in: logged_in? })
  end
end

# Process plan creation
#
# @see Model#save_plans
post '/plans' do
  require_login!
  monday = params[:monday_input]
  tuesday = params[:tuesday_input]
  wednesday = params[:wednesday_input]
  thursday = params[:thursday_input]
  friday = params[:friday_input]
  saturday = params[:saturday_input]
  sunday = params[:sunday_input]
  save_plans(session[:user_id], monday, tuesday, wednesday, thursday, friday, saturday, sunday)
  redirect '/plans/show'
end

# Process plan update
#
# @see Model#update_plan
post '/plans/:id/update' do
  require_login!
  plan = get_user_plan_by_id(params[:id])

  if plan && session[:user_id] == plan['UserID']
    update_plan(params[:id], params[:monday_input], params[:tuesday_input], params[:wednesday_input], params[:thursday_input], params[:friday_input], params[:saturday_input], params[:sunday_input])
    redirect '/plans'
  else
    flash[:error] = "You are not authorized to update this plan."
    redirect '/plans'
  end
end

# Process diet creation
#
# @see Model#save_diet
post '/diet' do
  require_login!
  diet_name = params[:diet_name_input]
  diet_info = params[:diet_info_input]
  name = params[:name_input]
  user_id = session[:user_id]
  save_diet(diet_name, diet_info, user_id, name)
  redirect '/diets/show'
end

# Process diet deletion
#
# @see Model#delete_diet
post '/diet/:id/delete' do
  require_login!
  diet_id = params[:id]
  delete_diet(diet_id)
  redirect '/diets/show'
end

# Process diet update
#
# @see Model#update_diet
post '/diet/:id/update' do
  diet_id = params[:id]
  diet_name = params[:diet_name_input]
  diet_info = params[:diet_info_input]
  name = params[:name_input]
  update_diet(diet_name, diet_info, name, diet_id)
  redirect '/diets/show'
end

# Process user deletion
#
# @see Model#delet_user
post '/user/:id/delete' do
  if admin_logged_in?
    user_id = params[:id]
    delet_user(user_id)
    redirect '/admin'
  else
    redirect '/home'
  end
end

# Process diet liking
#
# @see Model#like_diet
post '/diets/:id/like' do
  require_login!
  unless check_like(session[:user_id], params[:id])
    like_diet(session[:user_id], params[:id])
  end
  redirect back
end

# Process unliking a diet
#
# @see Model#unlike_diet
post '/diets/:id/unlike' do
  require_login!
  if check_like(session[:user_id], params[:id])
    unlike_diet(session[:user_id], params[:id])
  end
  redirect back
end

# Process user update
#
# @see Model#update_user
post '/user/:id/update' do
  if admin_logged_in?
    user_id = params[:id]
    name = params[:name_user]
    admin = params[:admin]
    if name && !name.empty?
      name.strip!
    else
      redirect '/admin'
    end
    update_user(name, admin, user_id)
    redirect '/admin'
  else
    redirect '/home'
  end
end