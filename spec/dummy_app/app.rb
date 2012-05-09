require 'sinatra'

get '/dummy' do
  File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'page.html'))
end
