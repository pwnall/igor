Seven::Application.routes.draw do |map|
  resources :team_partitions

  resources :teams

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
  resources :sessions
  resources :courses
  resources :prerequisites
  resources :recitation_sections
  resources :notices
  resources :assignment_metrics
  resources :run_results
  resources :assignment_feedbacks
  resources :assignments
  resources :deliverable_validations

  resources :users do
    collection do
      get :lookup, :recover_password
      post :check_name, :recovery_email
    end
    member { get :edit_password, :update_password }
  end
 
  resource :api, :controller => 'api' do    
    get :conflict_info
  end
  resources :deliverables do
    collection do
      get :xhr_description
    end
  end
  resources :grades do
    collection { get :request_report, :request_missing, :reveal_mine }
  end
  
  namespace :system do
    root :to => 'system/health#stat_system'
    resources :processes, :controller => 'health'
  end
  
  resources :profiles do
    collection do
      get :my_own
      post :websis_lookup
    end
  end
  resources :student_infos do
    collection { get :my_own }
  end
  resources :submissions do
    collection do
      get :request_package
    end
  end

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
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
  #       get :recent, :on => :collection
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
  # root :to => "welcome#index"
  root :to => "sessions#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  match 'tokens/:token', :to => 'tokens#spend', :as => :spend_token
end
