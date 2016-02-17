class Property < ActiveRecord::Base
	belongs_to :category
	validates_presence_of :name, :address, :latitude, :longitude, :category_id, :on => :create
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
