Voco::Application.routes.draw do
  resources :supports

  resources :routes

  root to: 'panel#index'
	mount API => '/api/'

  resources :offers, except: [:update, :edit]
  resources :rider_fares

  resources :rides

	get 'commuter_rides/schedule_trips' => 'commuter_rides#schedule_trips'
  resources :commuter_rides
	post 'commuter_rides/assemble_ride' => 'commuter_rides#assemble_ride'

  resources :fares

  resources :cars

  resources :devices

	post 'users/csv_import' => 'users#csv_import'
	resources :users

	post 'riders/csv_import' => 'riders#csv_import'
  resources :riders

	get 'drivers/:id/payout' => 'drivers#payout'
	post 'drivers/csv_import' => 'drivers#csv_import'
  resources :drivers

	get 'scheduler' => 'scheduler#index'
	delete 'scheduler/:id' => 'scheduler#failed'

	get 'panel' => 'panel#index'

	resources :payouts

	resources :payments
	
	get 'snapshots/latest' => 'snapshots#latest'

	resources :snapshots

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
