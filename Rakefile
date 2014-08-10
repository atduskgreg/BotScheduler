require './load_config' unless ENV["RACK_ENV"] == "production"
require './models'


desc "Send "

desc "Authorize a new bot."
task :add_bot do
	STDOUT.puts "Handle:"
	handle = STDIN.gets.strip

	bot = Bot.create :handle => handle
	bot.authorize_interactive!
end

desc "Sync data to heroku"
task :sync_heroku do
	puts `heroku pg:reset HEROKU_POSTGRESQL_GRAY_URL --confirm bot-scheduler`
	puts `heroku pg:push bot_scheduler HEROKU_POSTGRESQL_GRAY_URL`
end

desc "Send next tweet for each bot. Run by the Heroku scheduler"
task :send_tweets do
	Bot.verified_bots.each do |bot|
		bot.next_tweet.publish!
	end
end
