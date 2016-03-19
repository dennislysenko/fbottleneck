class Purger
  include Sidekiq::Worker

  @queue = :high

  def perform
    p 'performing purger task'

    User.all.each do |current_user|
      p "user #{current_user.id}: recent average api calls was #{current_user.average_api_calls_per_minute(5)}"
      p "user #{current_user.id}: hourly average api calls was #{current_user.average_api_calls_per_minute(5)}"
      unless current_user.should_make_api_call?
        p "skipping user #{current_user.id} because it doesn't think we should make an api call"
        next
      end

      graph = Koala::Facebook::API.new(current_user.access_token)

      notifications = graph.get_object('/me/notifications')
      current_user.api_calls.create!

      likes = notifications.select { |n| n['application'] != nil && n['application']['name'] == 'Likes' }
      p "User #{current_user.id} has #{notifications.count} notifications of which #{likes.count} are likes"
      likes.each do |notification|
        self.purge_notification(graph, current_user, notification['id'])
      end
    end
  end

  def purge_notification(graph, current_user, notification_id)
    result = graph.graph_call(notification_id, { unread: '0' }, 'post')
    current_user.api_calls.create!
    puts "purging notification #{notification_id} on user #{current_user.id}; result was #{result}"
  end
end

# Schedule this every 20 seconds.
Sidekiq::Cron::Job.create(
    name: 'Purger - every 20 seconds',
    cron: '*/20 * * * * *',
    class: 'Purger'
)
