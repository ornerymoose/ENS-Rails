class Property < ActiveRecord::Base
	#belongs_to :category

	has_many :categorizations
	has_many :categories, through: :categorizations

end
