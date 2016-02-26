class Subscription < ActiveRecord::Base
	has_many :categorizations
	has_many :categories, through: :categorizations

	belongs_to :user
	validates_presence_of :categories, :on => :create

	validate :mobile_phone_number

	def mobile_phone_number
		lookup_client = Twilio::REST::LookupsClient.new Rails.application.secrets.twilio_sid, Rails.application.secrets.twilio_token
		begin
			if self.phone_number.blank?
				return true
			end
			response = lookup_client.phone_numbers.get("#{self.phone_number}")
			response.phone_number #if invalid, throws an exception. If valid, no problems.
			return true
		rescue => e
			errors.add(:base, "That phone number is not valid.")
		end
	end



end
