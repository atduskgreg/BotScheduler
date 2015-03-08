require 'marky_markov'
require './models'

class DestinyEbooksBot
	def bot
		@bot ||= Bot.first :handle => "destiny_ebooks"
	end

	def handle
		bot.handle
	end

	def next_tweet
		markov = MarkyMarkov::Dictionary.new('destiny_ebooks/destiny-ebooks-dictionary')
		
		done = false
		result = nil
		
		while !done
			result = markov.generate_n_sentences 1
			if result.length <= 140
				done = true
			end
		end
		
		return bot.tweets.create :text => result
	end
end