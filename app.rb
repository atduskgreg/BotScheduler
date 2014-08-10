require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require './models'

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