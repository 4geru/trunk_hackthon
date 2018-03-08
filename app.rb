require 'bundler/setup'
Bundler.require
require 'sinatra'
require 'line/bot'
require './src/hello'
require './models'
require 'dotenv'
Dotenv.load

# 微小変更部分！確認用。
get '/' do
  "Hello world"
end

require './src/line'