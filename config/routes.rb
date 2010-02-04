ActionController::Routing::Routes.draw do |map|
  map.resources :courses

  map.resources :prerequisites

  map.resources :users, :collection => { :lookup  => :get,
                                         :check_available => :get,
                                         :recover_password => :get },
                        :member => { :edit_password => :get,
                                     :update_password => :put }
  map.resources :sessions
  map.resources :api, :collection => { :conflict_info => :get }

  map.resources :recitation_sections
  map.resources :notices
  map.resources :assignment_metrics
  map.resources :run_results
  map.resources :assignment_feedbacks
  map.resources :assignments
  map.resources :deliverables
  map.resources :deliverable_validations
  map.resources :student_infos, :collection => { :my_own => :get }
  map.resources :submissions, :collection => { :request_package => :get }
  map.resources :profiles
  map.resources :health, :collection => { :system_stat => :get }
  map.resources :grades, :collection => { :request_report => :get,
                                          :request_missing => :get  }

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'sessions'
  
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect 'tokens/:token', :controller => 'tokens', :action => 'spend'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
