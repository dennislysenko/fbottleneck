Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
           scope: 'manage_notifications',
           client_options: {
               site: 'https://graph.facebook.com/v2.0',
               authorize_url: 'https://www.facebook.com/v2.0/dialog/oauth',
               token_url: 'oauth/access_token'
           }
end