# noinspection RubyInstanceMethodNamingConvention
class User < ActiveRecord::Base
  has_many :api_calls

  def allowed_api_calls_per_hour
    200
  end

  def estimated_allowed_api_calls_per_minute
    allowed_api_calls_per_hour / 60
  end

  def safe_allowed_api_calls_per_minute
    estimated_allowed_api_calls_per_minute * 0.9 # just to be on the safe side we'll stick 10% below the limit.
  end

  def average_api_calls_per_minute(in_past_minutes)
    relevant_calls = api_calls.where('created_at > ?', Time.now - in_past_minutes.minutes)#.count / in_past_minutes
    return 0 if relevant_calls.empty?

    seconds_since_first = Time.now.to_f - relevant_calls.order(created_at: :asc).first.created_at.to_f
    minutes_since_first = seconds_since_first / 60

    p "past minutes #{in_past_minutes}; relevant calls count was #{relevant_calls.count}; minutes_since_first was #{minutes_since_first}"

    relevant_calls.count / minutes_since_first
  end

  def should_make_api_call?
    average_api_calls_per_minute(5) <= safe_allowed_api_calls_per_minute &&
        average_api_calls_per_minute(60) <= safe_allowed_api_calls_per_minute
  end
end
