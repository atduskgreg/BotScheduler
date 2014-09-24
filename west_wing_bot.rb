require './models'
require 'ferret'
require 'open-uri'
require 'nokogiri'
require 'engtagger'

class WestWingBot
	def bot
		@bot ||= Bot.first :handle => "jedsthirdterm"
	end

	def handle
		bot.handle
	end

	def tags_for_headline(headline)
		tgr = EngTagger.new
		tags = tgr.get_proper_nouns(tgr.add_tags(headline))
		tags.keys.collect{|k| "##{k}"}
	end

	def next_tweet
		index = Ferret::Index::Index.new(:default_field => 'content', :path => 'ferret-index')
		url = "https://news.google.com/news/"
		doc = Nokogiri::HTML(open(url))
		headlines = doc.css('.titletext').collect{|n| n}

		tweet = nil

		headlines.shuffle.each do |headline|
			text = headline.text
			link = headline.parent.attributes["href"].value
		
			tweetables = []
			index.search_each(text) do |doc, score| 
				txt = index[doc]['file']

				short_url_length = 23

				if txt.length <= (140-(short_url_length+1)) && score > 0.5
					t = "#{txt} #{link}"
					tags = tags_for_headline(text)
					puts "tags"
					puts tags.inspect	
					current_tag = 0
					added_tags = []
					
					tags.each do |tag|
						tags_to_add = added_tags + [tag]
						candidate = "#{txt} #{tags_to_add.join(" ")}"
						if candidate.length <= (140-(short_url_length+1))
							t = candidate
							added_tags << tag
						end
					end	

					if added_tags.length > 0
						t << " #{link}"
					end

					tweetables << t
				end

				
			end
			if !tweetables.empty?
				tweet = bot.tweets.create :text => tweetables.sample
				break
			end

		end

		return tweet
	end
end