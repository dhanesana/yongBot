yongBot - super cool IRC bot built using the [Cinch IRC Bot Building Framework](https://github.com/cinchrb/cinch)
=====================================

Description
-----------

yongBot is an IRC bot built packed with useful and fun plugins pertaining to music, gaming, sports, and more!

For general support, join [#yongBot](http://webchat.snoonet.org/yongbot).

Installation
------------

yongBot was created to run on [Heroku](https://www.heroku.com/) and uses PostgreSQL for data persistence. Sensitive information such as API keys are stored within environment variables. If running the bot locally, I recommend adding [dotenv](https://github.com/bkeepers/dotenv) to your gemfile and loading it in **yong_bot.rb**.

### Dependencies

#### Ruby Gems

yongBot has numerous gem and API dependencies. API keys must be obtained externally, but gems are installed with [Bundler](http://bundler.io/).

#### Configuration

Create a .env file within the root directory, and populate with the following variables and values ([syntax](https://github.com/bkeepers/dotenv)):

**_Note: Review the terms and conditions of each API before registering._**

| ENV Variable       | Value
| -------------      |:-----:
| APP_NAME           | *Heroku App Name*
| SERVER             | *IRC Server (ex. irc.snoonet.org)*
| CHANNELS           | *IRC #Channels (with hash, comma-seperated, no spaces)*
| NICKS              | *Bot IRC Nickname*
| PW                 | *Password for registered bot nickname*
| MASTER             | [Your IP Host & Domain](http://www.ircbeginner.com/opvinfo/masks.html)
| HEROKU_API         | [Heroku API Key](https://dashboard.heroku.com/account)
| HEROKU_BOT_HIGH    | 1
| HEROKU_BOT_LOW     | 0
| DAUM_KEY           | [Daum API Key](https://developers.daum.net/services)
| EBAY_ID            | [eBay AppID](https://go.developer.ebay.com/)
| FACEPLUS_KEY       | [Face++ API Key](http://www.faceplusplus.com/create-a-new-app/)
| FACEPLUS_SECRET    | [Face++ API Secret](http://www.faceplusplus.com/create-a-new-app/)
| FLICKR_KEY         | [Flickr API Key](https://www.flickr.com/services/api/misc.api_keys.html)
| GITHUB_ID          | [GitHub Client ID](https://github.com/settings/applications/new)
| GITHUB_SECRET      | [GitHub Client Secret](https://github.com/settings/applications/new)
| GOOGLE             | [Google API Key](https://cloud.google.com/translate/v2/getting_started)
| IG_ID              | [Instagram Client ID](https://instagram.com/developer/)
| KMF_LOGIN          | [Korea Times ID](https://ticket.koreatimes.com/member/login.html)
| KMF_PW             | [Korea Times Password](https://ticket.koreatimes.com/member/login.html)
| MASHAPE_KEY        | [Mashape API Key](http://docs.mashape.com/api-keys)
| NUTRITIONX_ID      | [Nutritionix AppID](https://www.nutritionix.com/api)
| NUTRITION_KEY      | [Nutritionix API Key](https://www.nutritionix.com/api)
| RAPGENIUS          | [Genius Access Token](http://genius.com/api-clients)
| REKOGNITION_KEY    | [ReKognition API Key](https://rekognition.com/developer/start)
| REKOGNITION_SECRET | [ReKognition API Secret](https://rekognition.com/developer/start)
| SC_ID              | [SoundCloud Client ID](https://developers.soundcloud.com/docs/api/guide)
| STEAM_KEY          | [Steam API Key](http://steamcommunity.com/dev)
| TIMEZONE           | [TimeZoneDB API Key](http://timezonedb.com/)
| TUMBLR_KEY         | [Tumblr API Key](https://www.tumblr.com/docs/en/api/v2)
| TWITCH_CHANNELS    | *IRC #Channels for Twitch plugin announcements (with hash, comma-seperated, no spaces)*
| TWITCH_USERS       | [Twitch.tv](http://www.twitch.tv/) Users (comma-seperated, no spaces)
| VIKI               | [Viki AppID](http://dev.viki.com/)
| WA_ID              | [Wolfram Alpha AppID](http://products.wolframalpha.com/api/)
| WEATHER_KEY        | [OpenWeatherMap API Key](http://openweathermap.org/appid#get)

Usage
-----

### Deploying to [Heroku](https://www.heroku.com/)

Run the following commands from within the root directory to create your Heroku app:

```
heroku create [App Name]
```

If the app name is taken, pick a new one and make sure to update your .env file accordingly.
Push your .env configuration to heroku using the following rake command:

```
rake config:push
```

Once your app is created and your configuration is set, run these last two commands to start up your bot:

```
heroku scale web=0
heroku scale bot=1
```

Keep in mind that bots depoloyed to Heroku will run 24/7. Scale your bot to 0 to shut it down.
To auto-scale your bot according to time of day, install [Heroku Scheduler](https://addons.heroku.com/scheduler) and schedule the following rake tasks:

```
rake scale_down
```
```
rake scale_up
```

### IRC Identification

yongBot uses the [Identify Plugin](https://github.com/cinchrb/cinch-identify) to identify registered bot nicknames. yongBot is currently configured to identify with NickServ. To change service, locate the **yong_bot.rb** file and modify the following line to specify type of authentication:

```
:type => :nickserv
```

*Warning: When using the :nickserv, :dalnet, :userserv, :quakenet or :kreynet types, the password will appear in the logs.*

### Bot Commands

yongBot has a large assortment of fun and useful commands. All commands have a dot prefix. To view a list of available commands, enter the following IRC message:

```
.help
```

For more information on specific commands, enter the following IRC messsage:

```
.help [command name without prefix dot]
```

The following commands may only be used by the *MASTER* user:

| Master Command        | Description
| --------------        |:-----------:
| .join [channel]       | Bot joins specified channel
| .part [channel]       | Bot leaves specified channel
| .setnick [nickname]   | Updates bot nickname
| .ping                 | Replies with the nick of every user in channel
| .echo [channel] [msg] | Outputs a message to specified channel
| .notice               | Replies via notice
| .notice [nick] [msg]  | Sends a notice to specified user
