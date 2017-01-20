ActiveAdmin.register Ticket do

	permit_params :event_status, :event_severity, :event_category, :problem_statement, :additional_notes, :bridge_number, :heat_ticket_number, :customers_affected, :property_ids => []

    # member_action :show do
    #     @ticket = Ticket.includes(versions: :item).find(params[:id])
    #     @versions = @ticket.versions 
    #     @ticket = @ticket.versions[params[:version].to_i].reify if params[:version]
    #     show! #it seems to need this
    # end

	form do |f|
		f.inputs "Ticket Details" do
			f.input :event_status
	      	f.input :event_severity
	      	f.input :event_category
	      	f.input :problem_statement
	      	f.input :additional_notes
	      	f.input :bridge_number
	      	f.input :heat_ticket_number
	      	f.input :customers_affected
	      	f.input :properties, as: :check_boxes	      	
	    end
		f.button "Update This Ticket"
	end

	csv do
        column(:ModifiedBy) { |t|
            widget = Ticket.find(t.id)
            v = widget.versions.last
            u = User.find_by_id(v.whodunnit)
            "#{u.email}"
        }
    	column :heat_ticket_number
    	column :event_category
    	column :event_severity
    	column :customers_affected
    	column :services_affected
    	column :problem_statement
    	column :created_at
    	column :completed_at
    	column(:duration) {|t| 
    		if !t.completed_at.nil?
                Time.at(t.completed_at - t.created_at).utc.strftime("%H:%M:%S")
    		end
    	}	
    	column :resolution
    	column :event_status
    	column :bridge_number
    	column :additional_notes
  	end

end
