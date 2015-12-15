ActiveAdmin.register User do
 
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :email, :role
 
    index do
        column :email
        column :current_sign_in_at
        column :last_sign_in_at
        column :sign_in_count
        column :role
        actions
    end
 
    filter :email
 
    form do |f|
        f.inputs "User Details" do
            f.input :email
            f.input :role, as: :radio, collection: {Administrator: "admin", EnsAdministrator: "ens_admin", EnsViewer: "ens_viewer"}
        end
        f.actions
    end
 
end