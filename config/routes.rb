Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users
  resources :tickets
  resources :subscriptions
  resources :categorizations
  resources :properties
  resources :categories

  #route for carrier and enterprise locs
  get '/carrier_and_enterprise_locs', to: 'subscriptions#carrier_and_enterprise_locs'

  #route to show papertrail history of who is updating the additional_notes column on the Ticket model
  get '/history_notes', to: 'tickets#history_notes'

  #custom routes for closing a ticket
  get '/tickets/:id/close' => 'tickets#close', as: :close
  patch 'tickets/:id/close' => 'tickets#close_update'

  root 'tickets#index'
  get "*path" => redirect("/")
end
