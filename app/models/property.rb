class Property < ActiveRecord::Base
	belongs_to :category
	validates_presence_of :name, :address, :latitude, :longitude, :category_id, :on => :create

	default_scope { order('name asc') }

	def property_name_and_address
		if self.address == ""
			"#{self.name}"	
		else 
			"#{self.name} - #{self.address} - #{self.category.name}"
		end
	end
end
