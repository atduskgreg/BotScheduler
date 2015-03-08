require './load_config' unless ENV["RACK_ENV"] == "production"
require './models'
require './west_wing_bot'
require './lifetoll_bot'
require './literaldevices/literal_devices_bot'
require './destiny_ebooks_bot'

desc "Authorize a new bot."
task :add_bot do
	STDOUT.puts "Handle:"
	handle = STDIN.gets.strip

	bot = Bot.create :handle => handle
	bot.authorize_interactive!
end

desc "Sync data _to_ heroku"
task :sync_to_heroku do
	puts `heroku pg:reset HEROKU_POSTGRESQL_GRAY_URL --confirm bot-scheduler`
	puts `heroku pg:push bot_scheduler HEROKU_POSTGRESQL_GRAY_URL`
end

desc "Sync data _from_ heroku"
task :sync_from_heroku do
	puts `dropdb bot_scheduler`
	puts `heroku pg:pull HEROKU_POSTGRESQL_GRAY_URL bot_scheduler`
end

desc "Send next tweet for each bot with a normal schedule. Run by the Heroku scheduler"
task :send_tweets do
	bots = Bot.verified_bots("normal").to_ary
	bots << DestinyEbooksBot.new
	bots << LifetollBot.new
	bots << LiteralDevicesBot.new
	bots.each do |bot|
		begin
			bot.next_tweet.publish!
		rescue Exception => e
			puts "ERROR: Problem posting for #{bot.handle}"
			puts "#{e.inspect}: #{e.message}" 
		end
	end
end

desc "Send tweets for bots with the daily schedule"
task :send_daily do
	Bot.verified_bots("daily").each do |bot|
		begin
			bot.next_tweet.publish!
		rescue Exception => e
			puts "ERROR: Problem posting for #{bot.handle}"
			puts "#{e.inspect}: #{e.message}" 
		end
	end
end

desc "Send tweet for special West Wing bot"
task :tweet_west_wing do
	bot = WestWingBot.new
	begin
		bot.next_tweet.publish!
	rescue Exception => e
		puts "ERROR: Problem posting for #{bot.handle}"
		puts "#{e.inspect}: #{e.message}" 
	end
end