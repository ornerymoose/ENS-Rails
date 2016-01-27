class User < ActiveRecord::Base
	before_save :generic_role

  	devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    has_one :subscription
    has_many :tickets

	def role?(r)
  		role.include? r.to_s
	end

	def generic_role
		#if users email address is within array
		if self.email.in?("ENV['NOC_TECHS']")
			self.role ||= "ens_admin"
		else
			self.role ||= "ens_viewer"
		end
	end
end
