Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users
  resources :tickets#, :except => [:show]
  resources :subscriptions
  resources :categorizations
  resources :properties
  resources :categories
  get '/history', to: 'tickets#history'

  #custom routes for closing a ticket
  get '/tickets/:id/close' => 'tickets#close', as: :close
  patch 'tickets/:id/close' => 'tickets#close_update'

  root 'tickets#index'
  get "*path" => redirect("/")
end
