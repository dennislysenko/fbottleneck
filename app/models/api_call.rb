class ApiCall < ActiveRecord::Base
  belongs_to :user

  scope :in_last_hour, -> { where('created_at > ?', Time.now - 1.hour) }
end
