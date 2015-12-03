class Ticket < ActiveRecord::Base
	has_many :categorizations
	has_many :properties, through: :categorizations
end
