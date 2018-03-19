require 'sinatra/reloader'
require 'net/http'
require 'json'
require 'time'
require 'pp'
require 'bundler'
require './models/users'
require './models/checkins'
require './history.rb'
Bundler.require
enable :sessions
Dotenv.load

APP_SECRET = ENV['APP_SECRET']
APP_ID = ENV['APP_ID']

class SinatraOmniAuth < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end

  use OmniAuth::Builder do
    provider :facebook, APP_ID, APP_SECRET,
    scope: 'email, user_birthday, public_profile, user_posts',
    display: 'popup',
    info_fields: 'id, name, email, birthday, gender, first_name, last_name, posts'
  end

  helpers do
    def get_alphabet(n)
      ('A'[0].ord + n).chr
    end
  end

  get '/' do
    session[:access_token] = nil
    erb :top
  end

  get '/auth/:provider/callback' do
    @provider = params[:provider]
    pp @result = request.env['omniauth.auth']
    @user = User.create(
      access_token: @result['credentials']['token'],
      name: @result['extra']['raw_info']['name'],
      fb_id: @result['extra']['raw_info']['id']
    )
    session[:access_token] = @user.access_token
    session[:user_id] = @user.id
    session[:name] = @user.name
    redirect '/index'
  end

  get '/index' do
    redirect '/' if session[:access_token].nil?
    @since_time = session[:since_time].nil? ? '2017/01/01' : session[:since_time]
    @until_time = session[:until_time].nil? ? '2018/01/01' : session[:until_time]
    pp @sum_distance = $sum_distance.nil? ? 0 : $sum_distance
    puts "sum_distance:#{@sum_distance}"
    @user_id = session[:user_id]
    @checkins = []
    if Checkin.where(user_id: @user_id)
      pp @checkins = Checkin.where(user_id: @user_id)
    end
    erb :index
  end

  post '/search' do
    $sum_distance = 0
    @user_id = session[:user_id]
    session[:since_time] = params[:since_time]
    session[:until_time] = params[:until_time]
    Checkin.where(user_id: @user_id).destroy_all
    EM::defer do
      p 'operation started!'
      my_history = History.new(session[:access_token])
      pp @checkins = my_history.gets_data(session[:since_time], session[:until_time])
      pp $sum_distance = @checkins.empty? ? 0 : my_history.calculation(@checkins)
      puts "sum_distance:#{$sum_distance}"
      @checkins.each do |checkin|
        Checkin.create(
          name: checkin['name'],
          time: checkin['time'],
          lat: checkin['lat'],
          lng: checkin['lng'],
          user_id: @user_id
        )
      end
      p 'operation finished!'
    end
    redirect '/index'
  end

  get '/about' do
    erb :about
  end

  get '/rule' do
    erb :rule
  end

  get '/policy' do
    erb :privacypolicy
  end

  error do
    'Sorry there was a nasty error - ' + env['sinatra.error'].message
  end

end
SinatraOmniAuth.run! if __FILE__ == $0
