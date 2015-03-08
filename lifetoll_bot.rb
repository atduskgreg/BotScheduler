require './models'
require 'csv'

class LifetollBot
	def bot
		@bot ||= Bot.first :handle => "lifetoll"
	end

	def handle
		bot.handle
	end

	def next_tweet
		events = open("lifetoll/events.txt").read.split(/\n/)
		disasters = CSV.parse(open("lifetoll/disasters.csv").read)

		event = events.sample
		disaster = disasters.sample
	
		amt = disaster[0]
		name = disaster[1]
	
		comparison = ["like", "a bit like", "comparable to"]
		killed = [", killing", " which killed", ", leading to the deaths of", ", responsible for the deaths of"]

		return bot.tweets.create :text => "#{event} #{comparison.sample} the #{name}#{killed.sample} #{amt}." 
	end
end