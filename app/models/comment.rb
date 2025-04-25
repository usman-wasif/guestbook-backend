class Comment < ApplicationRecord
    validates :message, presence: true
    validates :name, presence: true

    scope :recent_non_spam, -> { where(is_spam: false).order(created_at: :desc).limit(50) }
end
