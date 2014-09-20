require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require './load_config' unless ENV["RACK_ENV"] == "production"
require './models'

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['ADMIN_CREDENTIALS_USER'], ENV['ADMIN_CREDENTIALS_PASS']]
  end

end

before do
	protected!
end

get "/" do
	@bots = Bot.all
	erb :index
end

get "/bots/:bot" do
	@bot = Bot.first :handle => params[:bot]
	erb :bot
end

get "/bot/new" do
	erb :new
end

get "/tweets/edit/:tweet_id" do
	@tweet = Tweet.get params[:tweet_id]
	erb :edit
end

post "/tweets/:tweet_id" do
	@tweet = Tweet.get params[:tweet_id]
	@tweet.text = params["text"]
	@tweet.save

	redirect "/bots/#{@tweet.bot}"
end

post "/tweets/delete/:tweet_id" do
	@tweet = Tweet.get params[:tweet_id]
	@tweet.destroy
	redirect "/bots/#{@tweet.bot}"
end

get "/authorize/:bot" do
	@bot = Bot.first :handle => params[:bot]
	erb :authorize
end

get "/oauth/confirm/:bot" do
	@bot = Bot.first :handle => params[:bot]
	request_token = @bot.request_token_oauth

	result = @bot.authorize_token_from_callback request_token, params[:oauth_verifier]
	if result.authorized?
		@bot.twitter_token = result.token
		@bot.twitter_secret = result.secret
		@bot.verified = true
		@bot.save
	end

	redirect "/bots/#{@bot}"
end

post "/authorize/:bot" do
	bot = Bot.first :handle => params[:bot]
	bot.authorize_token_from_code params["pin"]

	redirect "/bots/#{bot}"
end

post "/bots" do
	bot = Bot.create :handle => params["handle"]

	redirect "/authorize/#{bot.handle}"
end

post "/:bot/tweets" do
	bot = Bot.first :handle => params[:bot]
	bot.tweets.create :text => params["text"]

	redirect back
end

post "/tweets/publish/:tweet_id" do
	tweet = Tweet.get params[:tweet_id]
	tweet.publish!

	redirect back
end