require 'sidekiq/web'

Rails.application.routes.draw do
  post '/users/authenticate'

  root 'static_pages#index'
  get '/notifications', to: 'static_pages#notifications'
  get '/deactivate', to: 'static_pages#deactivate'
  get '/auth/facebook/callback', to: 'users#authenticate'

  mount Sidekiq::Web => '/admin/sidekiq'
end