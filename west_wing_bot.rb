require './models'
require 'ferret'
require 'open-uri'
require 'nokogiri'


class WestWingBot
	def bot
		@bot ||= Bot.first :handle => "jedsthirdterm"
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
				t = "#{txt} #{link}"
				if t.length <= 140 && score > 0.5
					tweetables << "#{t} [#{t.length}]"
				end
			end
		
			if !tweetables.empty?
				tweet = Tweet.create :text => tweetables.sample
				break				
			end
		end

		return tweet
	end
end