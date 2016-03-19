# fbottleneck
Automatically dismisses 'like' and 'reaction' notifications on Facebook; requires an app running on Graph API version 2.3 or lower

## setup
First, find an app you've registered on the Facebook Developer site that is running Graph API version 2.3 or lower (latest version of the graph API does not allow you to request manage_notifications permission): https://developers.facebook.com/apps/

Fire up a server on your preferred host, and on the server:
- do the instructions on http://rvm.io/
- apt-get (or whatever pacman you prefer) install redis-server, postgres, libpq-dev, possibly some other stuff
- setup a postgresql database and a user with full permissions to it, save the database name, user's username and password now

On your personal computer:
- make sure you have ruby, follow the instructions on http://rvm.io/ to install it if you don't; install with bundler if that is an option
- clone this repo
- create a file `config/deploy/production.rb` with the text:
```
server 'YOUR.SERVER.IP', user: 'YOUR.SERVER.SSH.USER', roles: %w[web app db sidekiq_worker sidekiq_scheduler sidekiq]
set :workers, high: 4, low: 1, '*' => 2
set :nginx_server_name, 'YOUR.SERVER.IP YOUR.SERVER.SUBDOMAIN.IF.YOU.WANT ANYTHING.ELSE.YOU.DESIRE'
```
- run `bundle` to install dependencies
- run `bundle exec cap production setup` to set up your server

On the server again:
- Create a file ~/fbottleneck/shared/.env, and populate it with:
```
FACEBOOK_APP_ID=YOUR FACEBOOK APP ID
FACEBOOK_APP_SECRET=YOUR FACEBOOK APP SECRET
REDIS_URL=redis://localhost:6379/0
DATABASE_NAME=the name of the postgres database you created
DATABASE_USERNAME=the name of the postgres user with perms to that database
DATABASE_PASSWORD=the password to that postgres user
```

On your personal computer again:
- `bundle exec cap production deploy`

Raise an issue on this repo if these instructions don't work. If you raise an issue and your facebook app is registered on a new graph api version, I will be severely disappointed.

### heroku
You'll probably have to edit the scheduling. Right now this relies on sidekiq to schedule the "like dismissing" job every 20 seconds, and I doubt that's compatible with heroku.
