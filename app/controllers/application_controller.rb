class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => exception.message
    #render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end

  #cancan
  #check_authorization
  
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :remove_authentication_flash_message_if_root_url_requested

  def authenticate_active_admin_user!
  	authenticate_user!
   	unless current_user.role?(:admin)
    	flash[:alert] = 'You are not authorized to access this resource!'
      	redirect_to root_path
   	end
  end

  def remove_authentication_flash_message_if_root_url_requested
    if session[:user_return_to] == root_path and flash[:alert] == I18n.t('devise.failure.unauthenticated')
      flash[:alert] = nil
    end
  end

end
