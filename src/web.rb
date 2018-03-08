require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'date'
require 'net/http'
require 'uri'
require "base64"
enable :sessions

# トップページ
get '/' do
    if session[:user].nil?
        if params[:word].present?
            @events = Event.where("event_name like ?", "%#{params[:word]}%")
        else
            @events = Event.all
        end
        erb :index
    else
        redirect "/user/#{session[:user]}"
    end
end

# アカウント関係
get '/user' do
    if session[:user].nil?
        if params[:state] == "12345abcde"
            uri = URI.parse("https://api.line.me/oauth2/v2.1/token")
            # form-urlencodedフォーマット
            body = {
                grant_type: "authorization_code",
                code: params[:code],
                redirect_uri: "https://trunk-hackers-a4geru.c9users.io/user",
                client_id: "1567041353",
                client_secret: "e8226db48fdb1bfd15dbed97384701a1",
                }
            res = Net::HTTP.post_form(uri, body)
            parsed_json = JSON.parse(res.body)
            
            id_token = parsed_json["id_token"]
            arr = id_token.split(".")
            original = Base64.urlsafe_decode64(arr[1]) 
            json = JSON.parse(original)
            
            @user_id = json["sub"]
            @user_name = json["name"]
            @img = json["picture"]
            
            if User.find_by(user_id: @user_id).nil?
                @user = User.create(
                    user_id: @user_id,
                    name: @user_name,
                    image_url: @img
                )
                if @user.persisted?
                  session[:user] = @user.id
                else
                    redirect '/'
                end
            else
                @user = User.find_by(user_id: @user_id)
                session[:user] = @user.id
            end
            @participants = Participant.find_by(user_id: @user_id)
            redirect "/user/#{session[:user]}"
        else
            redirect '/'
        end
    else
        redirect "/user/#{session[:user]}"
    end
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

#他のユーザーを閲覧する画面
get '/user/:id' do
    @user = User.find(params[:id])
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
        start_time: params[:start_time],
        end_time: params[:end_time],
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
    @participant = Participant.create(
        user_id: session[:user],
        event_id: params[:id]
    )
    redirect '/event/:id'
end

post '/event/:id/cancel' do
    Participant.find_by(event_id: params[:id], user_id: session[:user]).destroy
    redirect '/event/:id'
end