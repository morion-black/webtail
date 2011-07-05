# webtail
  require "rubygems"
  require "sinatra"
  require "haml"

  set :port, 4568

  get '/' do
      erb :index
  end
  
  put '/logs/:hostname' do
      data = request.body.read
      File.open("logs/#{params[:hostname]}", 'a') {|f| f.write(data) }
      puts data
  end
  
  get '/logs/:server' do
      erb :logs
  end