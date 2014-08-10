require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-aggregates'

require 'twitter_oauth'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/bot_scheduler")

class Bot
 
  include DataMapper::Resource
  
  property :id, Serial
  property :handle, String
  property :verified, Boolean, :default => false
  property :twitter_token, String
  property :twitter_secret, String

  has n, :tweets

  def authorize_interactive!
    
    puts "Make sure you are logged in as the desired twitter user, then:"
    puts "visit the URL and copy the code: "

    request_token = request_token_pin
    puts request_token.authorize_url

    code = gets.strip
    result = authorize_token_from_code request_token, code

    puts result.authorized?
  end

  def request_token_oauth
    client.request_token(:oauth_callback => "http://bot-scheduler.herokuapp.com/oauth/confirm/#{handle}")
  end

  def request_token_pin
    client.authentication_request_token(:oauth_callback => 'oob')
  end

  def authorize_token_from_callback token, oauth_verifier
    access_token = client.authorize(
      request_token.token,
      request_token.secret,
      :oauth_verifier => oauth_verifier
    )
    return access_token
  end

  def authorize_token_from_code token, code
    client.authorize(
        request_token.token,
        request_token.secret,
        :oauth_verifier => code
    )

    return access_token
  end

  def client
    return @client if @client

    @client = TwitterOAuth::Client.new(
      :consumer_key => ENV["twitter_consumer_key"],
      :consumer_secret => ENV["twitter_consumer_secret"]
    )
  end

  def to_s
    handle
  end

  def unpublished_tweets
    self.tweets.all :posted => false
  end

end

class Tweet
  include DataMapper::Resource
  
  property :id, Serial
  property :text, Text
  property :posted, Boolean, :default => false
  
  belongs_to :bot


  def publish!

  end

end

DataMapper.finalize