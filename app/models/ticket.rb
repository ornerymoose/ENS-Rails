class Ticket < ActiveRecord::Base
	has_many :categorizations
	has_many :properties, through: :categorizations
	belongs_to :user
	has_paper_trail
end
