require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require '../models.rb'
require 'date'
enable :sessions

# トップページ
get '/' do
    if params[:word].present?
        @events = Event.where("event_name like ?", "%#{params[:word]}%")
    else
        @events = Event.all
    end
    erb :index
end

# アカウント関係
# get '/signin' do
#     erb :sign_in
# end

# post '/signin' do
#     user = User.find_by(mail: params[:mail])
#     if user && user.authenticate(params[:password])
#         session[:user] = user.id
#     end
#     redirect '/'
# end

# get '/signup' do
#     erb :sign_up
# end

# post '/signup' do
#     @user = User.create(
#         username: params[:username],
#         mail: params[:mail],
#         password: params[:password],
#         password_confirmation: params[:password_confirmation]
#     )
#     if @user.persisted?
#         session[:user] = @user.id
#     end
#     redirect '/'
# end

# get '/signout' do
#     session[:user] = nil
#     redirect '/'
# end

get '/user/:id' do
    @user = User.find(params[:id])
    @participants = Participant.find_by(user_id: session[:user])
    erb :user
end

get '/user/:id/edit' do
    @user = User.find(params[:id])
    erb :edit_user
end

post '/user/:id/edit' do
    @user = User.find(params[:id])
    @user.save
    
    redirect '/user/:id'
end

# イベント関係
get '/event' do
   @events = Event.all
   erb :event
end

get '/event/:id' do
    @event = Event.find(params[:id])
    erb :event_detail
end

post '/event/new' do
    @event = Event.create(
        name: params[:name],
        user_id: session[:user],
        detail: params[:detail],
        start_date: params[:start_date],
        end_date: params[:end_date],
        image_url: params[:image_url]
    )
    redirect '/event/:id'
end

get '/event/:id/edit' do
    @event = Evnet.find(params[:id])
    erb :edit_event
end

post '/event/:id/edit' do
    @event = Event.find(params[:id])
    @event.save
    
    redirect '/event/:id'
end

get '/event/:id/delete' do
    Event.find(params[:id]).destroy
    redirect '/event'
end

post '/event/:id/join' do
    @participants = Participant.create(
        user_id: session[:user],
        event_id: params[:id]
    )
    
    redirect '/event/:id'
end

post '/event/:id/cancel' do
    Participant.find_by(event_id: params[:id], user_id: session[:user]).destroy
    redirect '/event/:id'
end
