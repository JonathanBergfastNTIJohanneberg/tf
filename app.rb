require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'

enable :sessions

get('/') do 
  slim(:layout)
end
