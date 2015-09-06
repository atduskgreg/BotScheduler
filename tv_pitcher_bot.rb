require './models'

class TVPitcherBot
  def bot
    @bot ||= Bot.first :handle => "tv_pitcher"
  end

  def handle
    bot.handle
  end

  def next_tweet
    cliches = open("tv_pitcher/cliches.txt").read.split(/\n/)
    title = cliches.sample.split(" ").collect{|c| c.capitalize}.join(" ")

    genres = open("tv_pitcher/genres.txt").read.split(/\n/)
    types = open("tv_pitcher/types.txt").read.split(/\n/)
    settings = open("tv_pitcher/settings.txt").read.split(/\n/)
    
    
    type = types.sample
    if %w{a e i o u}.include? type.split("").first
      leading_article = "An"
    else
      leading_article = "A"
    
    end


    intro = ["So it's called", "Here's the pitch:", "This is called", "The title is"].sample
    
    text =  "#{intro} \"#{title}\". It's #{leading_article.downcase} #{type} #{genres.sample} set #{settings.sample}." 

    return bot.tweets.create :text => text 
  end
end