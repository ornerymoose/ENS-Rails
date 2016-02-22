class Subscription < ActiveRecord::Base
	has_many :categorizations
	has_many :categories, through: :categorizations

	belongs_to :user
	validates_presence_of :categories, :on => :create

	validates_numericality_of :phone_number, :allow_nil => true,  :message => "has to be numbers only"
	validates :phone_number, phony_plausible: true, numericality: {only_integer: true}, :allow_blank => true, length: { minimum: 10 }
	phony_normalize :phone_number, default_country_code: 'US'
end
