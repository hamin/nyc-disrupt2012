require 'bundler'
Bundler.require
Dir.open("./config").each do |file|
  next if file =~ /^\./
  require "./config/#{file}"
end

require './main'
run Sinatra::Application