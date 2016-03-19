class UsersController < ApplicationController
  def authenticate
    # render json: auth_hash

    if auth_hash.present?
      fb_id = auth_hash['uid']
      name = auth_hash['info']['name']
      token = auth_hash['credentials']['token']
      expires_at = auth_hash['credentials']['expires_at']
    else
      fb_id = params[:facebook_id]
      name = params[:name]
      token = params[:access_token]
      expires_at = Time.now.to_i + params[:expires_in].to_i
    end

    # exchange token
    oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
    info = oauth.exchange_access_token_info(token)
    token = info['access_token']
    expires_at = Time.now.to_i + info['expires'].to_i

    @user = User.find_by(facebook_id: fb_id)

    attributes = { facebook_id: fb_id, name: name, access_token: token, token_expiry: expires_at }

    if @user.nil?
      @user = User.create!(attributes)
    else
      @user.update!(attributes)
    end

    session[:user_id] = @user.id

    if auth_hash.present?
      redirect_to 'static_pages#index'
    else
      render json: { success: true }
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth'] || {}
  end
end
