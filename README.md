## BotScheduler

A simple Sinatra app to help you schedule your clever bot tweets.

### Why?

I make twitter bots like <a href="http://twitter.com/uncannyxbot">@uncannyxbot</a> and <a href="http://twitter.com/rulesofcards">@rulesofcards</a>. Maybe I am an impure or lazy bot-author but my approach is usually to generate a large number of tweets from whatever algorithmic process I have conceived and then to filter them by hand for quality (and to "automate" certain processes I've been too lazy to program). As such, my bots are not fire-and-forget. I can't just write bot software and deploy it. Instead, I produce a bunch of tweets and then have to find a way to schedule them out for tweeting. This app is that way.

### Setup

This is a Sinatra app meant to be deployed on Heroku. I will assume you know how to deploy ruby apps on Heroku. The specifics you have to know are thus:

BotScheduler depends on a series of Heroku environment variables to do its work:

* TWITTER_CONSUMER_KEY
* TWITTER_CONSUMER_SECRET
* ADMIN_CREDENTIALS_USER
* ADMIN_CREDENTIALS_PASS

You can set these up using the <a href="https://devcenter.heroku.com/articles/config-vars">heroku config:set</a> command.

Also, to enable local development, rename the sample_config.yml file to config.yml and populate it with this same data. This file gets loaded up when needed locally to emulate these Heroku environment variables.

You'll also have to log in to migrate the database once you've created it in postgres:

    $ irb
    > require './models'
    > DataMapper.auto_migrate!

You'll only have to do this once to get started. Especially if you push your local database up to heroku (see below under Creating a New Bot).

### Creating a New Bot

If you've already created data in your deployed Heroku version, first sync that data down locally with:

    $rake sync_from_heroku

_Note: This will delete your local data and make your local db exactly like the one deployed on heroku. Use with care._

To create a new bot, run the rake command:

    $rake add_bot

It will prompt you for a bot handle and then walk you through the process of authenticating the bot. This will store the necessary twitter credentials locally in the database.

The final step is to push all your data back up to Heroku with the credentials for the new bot in place:

    $rake sync_to_heroku

Again, this will delete your data on Heroku and replace it with your local version.

I know this is somewhat awkward and hacky. I started implementing Twitter's OAuth from properly but it wasn't working for inscrutable reasons probably related to OAuth being worse than Ebola. Pull requests welcome.

## Actually Sending Tweets

You can actually schedule the sending of tweets using <a href="https://devcenter.heroku.com/articles/scheduler">Heroku's scheduler</a>. Create a job for "rake send_tweets" on whatever schedule you'd like. By default that task sends one random tweet for each bot currently in the system. If you'd like it to do something more complicated you can change that rake task. Again, pull requests welcome.

_NB: The Heroku Scheduler's times are given in UTC. Depending on where you live, you might find this confusing as I did and need to make recourse to [everytimezone](http://everytimezone.com/)._