require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative 'models.rb'

enable :sessions
include Models

$db = SQLite3::Database.new('db/ovning_urval.db')
$db.results_as_hash = true

def logged_in?
  !session[:user_id].nil?
end

helpers do
  def admin_logged_in?
    logged_in? && $db.execute("SELECT admin FROM user WHERE ID = ?", session[:user_id]).first["admin"] == 1
  end

  def require_login!
    redirect '/register' unless logged_in?
  end
end

before do
  # Allow users to access login and register without authentication
  pass if ['/', '/register', '/login', '/create_user'].include?(request.path_info)
  # Redirect to /register if the user is not logged in
  if session[:user_id].nil?
    session[:error] = "You must be logged in to access this page."
    redirect('/register')
    pass  # Ensure the remaining before filters are skipped
  end
end


before ['/admin/*'] do
  unless admin_logged_in?
    session[:error] = "You must be an admin to access this page."
    redirect('/home')
  end
end

before ['/plans/*', '/diets/*'] do
  require_login!
end

before ['/diets/new', '/diets/:id/edit', '/diets/:id/delete'] do
  require_login!
end

before ['/diet/:id/update', '/diet/:id/delete'] do
  diet = get_diet(params[:id])
  unless session[:user_id] == diet['UserID']
    status 403
    halt "You do not have permission to modify this diet."
  end
end

get '/' do
  slim(:'home/home', locals: { logged_in: logged_in? })
end

get '/home' do
  puts "Current user ID in session: #{session[:user_id]}"  # Debugging output
  slim(:'home/home', locals: { logged_in: logged_in? })
end


get '/register' do 
  slim(:'register/register', locals: { logged_in: logged_in? })
end 

get '/logout' do 
  session.clear
  redirect '/home'
end

get '/admin' do
  users = get_users 
  slim(:'admin/index', locals: { users: users })
end

get '/admin/edit' do
  users = get_users 
  slim(:'admin/edit', locals: { users: users })
end

get '/diets' do
  diets = get_diets
  slim(:'diets/index', locals: { logged_in: logged_in?, diets: diets})
end

get '/diets/new' do 
  diets = get_diets
  slim(:'diets/new', locals: {logged_in: logged_in?, diets: diets})
end 

get '/diets/index' do 
  diets = get_diets
  slim(:'diets/index', locals: {logged_in: logged_in?, diets: diets})
end 

get '/diets/show' do 
  diets = get_diets
  slim(:'diets/show', locals: {logged_in: logged_in?, diets: diets})
end 

get '/diets/:id/edit' do 
  diet = get_diet(params[:id])
  slim(:'diets/edit', locals: {logged_in: logged_in?, diet: diet})
end

get '/plans' do
  user_id = session[:user_id]
  plan = get_user_plan(user_id)
  p plan 
  slim(:'plans/index', locals: { logged_in: logged_in?, plan: plan })
end

get '/plans/show' do 
  user_id = session[:user_id]
  plans = get_user_plan(user_id)
  slim(:'plans/show', locals: { logged_in: logged_in?, plans: plans })
end

get '/plans/index' do 
  user_id = session[:user_id]
  plans = get_user_plan(user_id)
  slim(:'plans/index', locals: { logged_in: logged_in?, plans: plans })
end

get '/plans/new' do 
  user_id = session[:user_id]
  plans = get_user_plan(user_id)
  slim(:'plans/new', locals: { logged_in: logged_in?, plans: plans })
end

post '/login' do
  username = params[:username]
  password = params[:password]
  result = get_results(username)
  if result && BCrypt::Password.new(result["password"]) == password
    session[:user_id] = result["ID"]
    session[:name] = result["name"]
    redirect('/home')
  else
    "Incorrect username or password"
  end
end


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
    slim(:register, locals: { error_message: "Passwords do not match", logged_in: logged_in? })
  end
end

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

post '/diet' do
  require_login!
  diet_name = params[:diet_name_input]
  diet_info = params[:diet_info_input]
  name = params[:name_input]
  user_id = session[:user_id]
  save_diet(diet_name, diet_info, user_id, name)
  redirect '/diets/index'
end

post '/diet/:id/delete' do
  require_login!
  diet_id = params[:id]
  delete_diet(diet_id)
  redirect '/diets'
end

post '/diet/:id/update' do
  diet_id = params[:id]
  diet_name = params[:diet_name_input]
  diet_info = params[:diet_info_input]
  name = params[:name_input]
  update_diet(diet_name, diet_info, name, diet_id)
  redirect '/diets/show'
end

post '/user/:id/delete' do
  if admin_logged_in?
    user_id = params[:id]
    delet_user(user_id)
    redirect '/admin'
  else
    redirect '/home'
  end
end

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