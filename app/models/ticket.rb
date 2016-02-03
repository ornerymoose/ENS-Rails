class Ticket < ActiveRecord::Base
	has_many :categorizations
	has_many :properties, through: :categorizations
	belongs_to :user
	validates_presence_of :properties, :on => :create
	has_paper_trail

	#this will 'hide' tickets from tickets#index page if they have a completed_at value of nil. When a ticket is initially created,
	#it has a value of nil. completed_at will be set to Time.now when the ticket is closed, but not deleted (tickets never get deleted).
	scope :active, ->{
  		where(completed_at: nil)
	}
end
