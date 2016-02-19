class Subscription < ActiveRecord::Base
	has_many :categorizations
	has_many :categories, through: :categorizations

	belongs_to :user
	validates_presence_of :categories, :on => :create
	validates :phone_number, phony_plausible: true, numericality: true, :allow_blank => true, length: { minimum: 10 }
	phony_normalize :phone_number, default_country_code: 'US'
end
