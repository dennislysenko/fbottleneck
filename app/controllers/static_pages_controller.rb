class StaticPagesController < ApplicationController
  def index
    if logged_in?
      begin
        graph.get_object('/me')
      rescue
        session[:user_id] = nil
      end
    end

    @logged_in = logged_in?
  end

  def notifications
    notifications = graph.get_object('/me/notifications')
    current_user.api_calls.create!

    likes = notifications.select { |n| n['application'] != nil && n['application']['name'] == 'Likes' }
    others = notifications.reject { |n| n['application'] != nil && n['application']['name'] == 'Likes' }

    render json: { likes: likes.map { |notif| notif['id'] }, others: others.count, notifications: notifications }
  end

  def deactivate
    current_user.destroy!
    session[:user_id] = nil
    redirect_to 'static_pages#index'
  end

  protected
  def current_user
    @user ||= User.find(session[:user_id])
    @user
  end

  def logged_in?
    User.exists?(session[:user_id])
  end

  def graph
    @graph ||= Koala::Facebook::API.new(current_user.access_token)
    @graph
  end

  def purge_notification(notification_id)
    graph.graph_call(notification_id, { unread: '0' }, 'post')
    current_user.api_calls.create!
  end
end
