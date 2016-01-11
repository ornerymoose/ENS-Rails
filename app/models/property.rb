class Property < ActiveRecord::Base
	belongs_to :category

	#has_many :categorizations
	#has_many :categories, through: :categorizations
	def property_name_and_address
		if self.address == ""
			"#{self.name}"	
		else 
			"#{self.name} - #{self.address}"
		end
	end
end
