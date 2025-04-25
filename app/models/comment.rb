class Comment < ApplicationRecord
    validates :message, presence: true
    validates :name, presence: true
end
