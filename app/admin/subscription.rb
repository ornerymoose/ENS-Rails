ActiveAdmin.register Subscription do

	permit_params :name, :phone_number, :category_ids => []
	form do |f|
    	f.inputs "Subscription Details" do
    		f.input :name
          	f.input :phone_number
          	f.input :categories, as: :check_boxes
        end
        f.button "Update This Subscription"
    end

end
