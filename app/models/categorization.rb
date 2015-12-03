class Categorization < ActiveRecord::Base
	belongs_to :property
  	belongs_to :category

  	belongs_to :subscription

  	#new stuff
  	belongs_to :ticket
end
