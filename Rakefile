require './load_config'
require './models'

desc "Athorize a new bot."
task :add_bot do
	STDOUT.puts "Handle:"
	handle = STDIN.gets.strip

	bot = Bot.create :handle => handle
	bot.authorize_interactive!
end