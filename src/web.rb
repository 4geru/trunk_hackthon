require 'bundler/setup'
require './src/image_uploader'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'date'
require 'net/http'
require 'uri'
require "base64"
enable :sessions

Cloudinary.config do |config|
    config.cloud_name = ENV["CLOUD_NAME"] 
    config.api_key = ENV["CLOUDINARY_API_KEY"] 
    config.api_secret = ENV["CLOUDINARY_API_SECRET"] 
end

before do
  puts "before #{session[:user]}"
  puts "before #{params}"
end

# トップページ
get '/' do
    if session[:user].nil?
        if params[:keyword].present?
            words = params[:keyword].split(' ')
            @events = words.map{|w| Event.where("event_name like ?", "%#{w}%")}.flatten
        else
            @events = Event.all.reverse
        end
        @events = @events[0...10]
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
                redirect_uri: URI.encode "#{ENV["BASE_URL"]}/user",
                client_id: ENV["LINE_LOGIN_CLIENT_ID"],
                client_secret: ENV["LINE_LOGIN_SECRET"],
                }
            res = Net::HTTP.post_form(uri, body)
            parsed_json = JSON.parse(res.body)
            
            id_token = parsed_json["id_token"]
            arr = id_token.split(".")
            original = Base64.urlsafe_decode64(arr[1]) 
            json = JSON.parse(original)
            
            user_id = json["sub"]
            user_name = json["name"]
            img = json["picture"]
            
            if User.find_by(user_id: user_id).nil? # ユーザーがいないとき
                @user = User.create(
                    user_id: user_id,
                    name: user_name,
                    image_url: img
                )
                if @user.persisted?
                  session[:user] = @user.id
                else
                    redirect '/'
                    return
                end
            else # ユーザーがいた時
                @user = User.find_by(user_id: user_id)
                if @user.name.nil?
                    @user.update({
                        name: user_name,
                        image_url: img
                    })
                end
                session[:user] = @user.id
            end
            redirect "/user/#{session[:user]}"
            return
        else
            redirect '/'
            return
        end
    else
        redirect "/user/#{session[:user]}"
        return
    end
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

get '/user/:id' do
    puts params
    puts session[:user]
    @user = User.find(params[:id])
    @join_events = @user.participants.map{|p| p.event }
    @events = Event.all.reverse[0..3]
    erb :mypage
end

# イベント関係
get '/search' do
    if params[:keyword].present?
        @words = params[:keyword].split(' ')
        @events = @words.map{|w| Event.where("event_name like ?", "%#{w}%")}.flatten
    else
        @events = Event.all
        @words = 'keywordはありません'
    end
    
    @user = session[:user] ? User.find("#{session[:user]}") : nil
    erb :search
end

get '/event/new' do
    erb :event_create1
end

get '/event/:id' do
    @event = Event.find(params[:id])
    @user = User.find(session[:user]) if session[:user]
    erb :details
end

post '/event/new' do
    Event.create(
        event_name: params[:name],
        user_id: session[:user],
        address: params[:address],
        detail: params[:detail],
        start_time: params[:start_time],
        end_time: params[:end_time],
    )
    if params[:file]
        image_upload(params[:file], Event.last.id)
    end
    @event = Event.lasts
    redirect "/event/#{@event.id}"
end

post '/event/:id/join' do
    p session[:user]
    p params[:id]
    @participant = Participant.create(
        user_id: session[:user],
        event_id: params[:id]
    )
    redirect "/event/#{params[:id]}"
end

post '/event/:id/cancel' do
    puts params[:id]
    puts session[:user]
    puts Participant.find_by(event_id: params[:id], user_id: session[:user])
    Participant.find_by(event_id: params[:id], user_id: session[:user]).delete
    
    redirect "/event/#{params[:id]}"
end

get '/event/:id/delete' do
    Event.find(params[:id]).destroy
    redirect '/'
end