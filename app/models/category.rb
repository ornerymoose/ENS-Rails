class Category < ActiveRecord::Base
	#has_many :properties

	has_many :categorizations
	has_many :properties, through: :categorizations

end
