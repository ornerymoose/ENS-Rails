class Subscription < ActiveRecord::Base
	has_many :categorizations
	has_many :categories, through: :categorizations

	belongs_to :user
	validates_presence_of :categories, :on => :create
end
