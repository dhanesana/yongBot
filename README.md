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

yongBot has numerous gem and API dependencies. You must obtain your own API keys and credentials, but gems are installed with [Bundler](http://bundler.io/).

#### Configuration

Create a .env file within the yongBot directory, and populate with the following variables and values ([syntax](https://github.com/bkeepers/dotenv)):

**_Note: Review the terms and conditions of each API before registering._**

| ENV Variable           | Value
| -------------          |:-----:
| APP_NAME               | *Heroku App Name*
| AWS_ACCESS_KEY_ID      | [AWS Key ID](https://aws.amazon.com/)
| AWS_SECRET_ACCESS_KEY  | [AWS Secret Key](https://aws.amazon.com/)
| BEAM_USERS             | [Beam](https://beam.pro/) Users (comma-seperated, no spaces)
| SERVER                 | *IRC Server (ex. irc.snoonet.org)*
| CHANNELS               | *IRC #Channels (with hash, comma-seperated, no spaces)*
| DAUM_KEY               | [Daum API Key](https://developers.daum.net/)
| DICT_KEY               | [Merriam-Webster Dictionary API Key](https://www.dictionaryapi.com/)
| NICKS                  | *Bot IRC Nickname*
| PW                     | *Password for registered bot nickname*
| USER_MODES             | IRC User Modes (comma-seperated) (ex. B,I)
| MASTER                 | [Your IP Host & Domain](http://www.ircbeginner.com/opvinfo/masks.html)
| HEROKU_API             | [Heroku API Key](https://dashboard.heroku.com/account)
| HEROKU_BOT_HIGH        | 1
| HEROKU_BOT_LOW         | 0
| DAUM_KEY               | [Daum API Key](https://developers.daum.net/services)
| EBAY_ID                | [eBay AppID](https://go.developer.ebay.com/)
| FACEPLUS_KEY           | [Face++ API Key](https://www.faceplusplus.com/)
| FACEPLUS_SECRET        | [Face++ API Secret](https://www.faceplusplus.com/)
| FLICKR_KEY             | [Flickr API Key](https://www.flickr.com/services/api/misc.api_keys.html)
| GITHUB_ID              | [GitHub Client ID](https://github.com/settings/applications/new)
| GITHUB_SECRET          | [GitHub Client Secret](https://github.com/settings/applications/new)
| GOOGLE                 | [Google API Key](https://cloud.google.com/translate/v2/getting_started)
| IG_ID                  | [Instagram Client ID](https://instagram.com/developer/)
| KMF_LOGIN              | [Korea Times ID](https://ticket.koreatimes.com/member/login.html)
| KMF_PW                 | [Korea Times Password](https://ticket.koreatimes.com/member/login.html)
| MASHAPE_KEY            | [Mashape API Key](http://docs.mashape.com/api-keys)
| NUTRITIONX_ID          | [Nutritionix AppID](https://www.nutritionix.com/api)
| NUTRITION_KEY          | [Nutritionix API Key](https://www.nutritionix.com/api)
| PASTEBIN_KEY           | [Pastebin API Key](https://pastebin.com/api)
| RAPGENIUS              | [Genius Access Token](http://genius.com/api-clients)
| SC_ID                  | [SoundCloud Client ID](https://developers.soundcloud.com/docs/api/guide)
| STEAM_KEY              | [Steam API Key](http://steamcommunity.com/dev)
| TIMEZONE               | [TimeZoneDB API Key](http://timezonedb.com/)
| TUMBLR_KEY             | [Tumblr API Key](https://www.tumblr.com/docs/en/api/v2)
| TWITCH_ID              | [Twitch Client-ID](https://www.twitch.tv/settings/connections)
| TWITCH_CHANNELS        | *IRC #Channels for Twitch and Beam plugin announcements (with hash, comma-seperated, no spaces)*
| USER_MODES             | *Refer to your IRC server docs for applicable user modes* [ie](https://www.unrealircd.org/docs/User_modes)
| VIKI                   | [Viki AppID](http://dev.viki.com/)
| WA_ID                  | [Wolfram Alpha AppID](http://products.wolframalpha.com/api/)
| WEATHER_KEY            | [OpenWeatherMap API Key](http://openweathermap.org/appid#get)

Usage
-----

### Deploying to [Heroku](https://www.heroku.com/)

Run the following commands from within the yongBot directory to create your Heroku app:

```
$ heroku create [App Name]
```

If the app name is taken, pick a new one and make sure to update your .env file accordingly.
Using the preconfigured [dotenv-heroku](https://github.com/sideshowcoder/dotenv-heroku) gem, push your .env configuration to heroku using the following rake command (or manually through heroku app settings):

```
$ rake config:push
```

Once your app is created and your configuration is set, run these last two commands to start up your bot:

```
$ heroku scale web=0
$ heroku scale bot=1
```

### IRC Identification

yongBot uses the [Identify Plugin](https://github.com/cinchrb/cinch-identify) to identify registered bot nicknames. yongBot is currently configured to identify with NickServ. To change service, locate the **yong_bot.rb** file and modify the following line to specify type of authentication:

```
:type => :nickserv
```

*Warning: When using the :nickserv, :dalnet, :userserv, :quakenet or :kreynet types, the password will appear in the logs.*

### Bot Commands

yongBot has a large assortment of fun and useful commands. All commands have a dot prefix (can be reconfigured within yong_bot.rb). To view a list of available commands, enter the following IRC message:

```
> .help
```

For more information on specific commands, enter the following IRC messsage:

```
> .help [command name without prefix dot]
```

The following commands may only be used by the *MASTER* user:

| Master Command         | Description
| --------------         |:-----------:
| .join [#channel]       | Bot joins specified #channel
| .part [#channel]       | Bot leaves specified #channel
| .setnick [nickname]    | Updates bot nickname
| .ping                  | Replies with the nick of every user in #channel (up to 30 nicks for non-admin operators)
| .echo [#channel] [msg] | Outputs a message to specified #channel
| .notice                | Replies via notice
| .notice [nick] [msg]   | Sends a notice to specified user
| .ban [user host/mask]  | Toggles ban of specified user
| .switch                | Toggles use of the bot by non-master users on/off
