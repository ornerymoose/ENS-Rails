class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable


	before_save :generic_role

  	devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	def role?(r)
  		role.include? r.to_s
	end

	def generic_role
		self.role ||= "ens_viewer"
	end
end
