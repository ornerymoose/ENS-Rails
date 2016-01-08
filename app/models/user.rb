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
		self.role ||= "ens_viewer"
	end
end
