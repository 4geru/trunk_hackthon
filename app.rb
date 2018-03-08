require 'bundler/setup'
Bundler.require
require 'sinatra'
require 'line/bot'
require './src/hello'
require './models'
require 'dotenv'
Dotenv.load

require './src/line'
require './src/web'