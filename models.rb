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

  property :frequency, String, :default => "normal" # normal, daily

  has n, :tweets

  def self.verified_bots(frequency)
    all :verified => true, :frequency => frequency
  end

  def next_tweet
    self.unpublished_tweets.sample
  end

  def authorize_interactive!
    
    puts "Make sure you are logged in as the desired twitter user, then:"
    puts "visit the URL and copy the code: "

    request_token = request_token_pin
    STDOUT.puts request_token.authorize_url

    code = STDIN.gets.strip
    result = authorize_token_from_code( request_token, code )

    STDOUT.puts client.authorized?

    if client.authorized?
      puts "token: #{result.inspect}"
      self.twitter_token = result.token
      self.twitter_secret = result.secret
      self.verified = true
      self.save

      return result
    end

  end

  def request_token_oauth
    client.authentication_request_token(:oauth_callback => "http://bot-scheduler.herokuapp.com/oauth/confirm/#{handle}")
  end

  def request_token_pin
    client.authentication_request_token(:oauth_callback => 'oob')
  end

  def authorize_token_from_callback request_token, oauth_verifier
    client.authorize(
      request_token.token,
      request_token.secret,
      :oauth_verifier => oauth_verifier
    )
  end

  def authorize_token_from_code request_token, code
    client.authorize(
        request_token.token,
        request_token.secret,
        :oauth_verifier => code
    )
  end

  def client
    return @client if @client

    opts = {:consumer_key => ENV["TWITTER_CONSUMER_KEY"],
            :consumer_secret => ENV["TWITTER_CONSUMER_SECRET"]}

    if self.verified
      opts[:token] = self.twitter_token
      opts[:secret] = self.twitter_secret
    end

    @client = TwitterOAuth::Client.new(opts)

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
    bot.client.authorized?
    bot.client.update(text)

    self.posted = true
    self.save
  end

end

DataMapper.finalize