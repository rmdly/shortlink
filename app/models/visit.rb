class Visit < ApplicationRecord
  belongs_to :link, counter_cache: true

  normalizes :referrer,   with: ->(referrer)   { referrer.presence }
  normalizes :user_agent, with: ->(user_agent) { user_agent.presence }

  scope :newest_first, -> { order(created_at: :desc) }
end
