class Subscription < ActiveRecord::Base
	has_many :categorizations
	has_many :categories, through: :categorizations

	belongs_to :user
end
