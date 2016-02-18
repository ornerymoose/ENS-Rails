class Subscription < ActiveRecord::Base
	has_many :categorizations
	has_many :categories, through: :categorizations

	belongs_to :user
	validates_presence_of :categories, :on => :create
	validates :phone_number, numericality: true, length: { minimum: 10 }
end
