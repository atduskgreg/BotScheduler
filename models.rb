require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-aggregates'
require 'json'
require 'pgn'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/bot_scheduler")

class Bot
 
  include DataMapper::Resource
  
  property :id, Serial
  property :handle, String

  has n, :tweets

end

class Tweet
  include DataMapper::Resource
  
  property :id, Serial
  property :text, Text
  property :posted, Boolean, :default => false
  

  belongs_to :bot

end

DataMapper.finalize