Seven::Application.routes.draw do |map|
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
  resources :recitation_sections  
  resources :run_results
  resources :survey_questions
  resources :team_memberships
  resources :team_partitions
  
  resources :users do
    collection do
      get :lookup, :recover_password
      post :check_name, :recovery_email
    end
    member do
      get :edit_password
      post :impersonate, :set_admin
      put :update_password
    end
  end
   
  resource :api, :controller => 'api' do
    get :conflict_info
  end
  resources :assignment_metrics do
    member do
      post :set_assignment_metric_assignment_id
      post :set_assignment_metric_max_score
      post :set_assignment_metric_name
      post :set_assignment_metric_published
      post :set_assignment_metric_weight
    end
  end
  resources :assignments do
    member do
      post :set_assignment_name
    end
  end
  resources :courses do
    member do
      post :set_course_ga_account
      post :set_course_has_recitations
      post :set_course_number
      post :set_course_title
    end    
  end
  resources :deliverables do
    collection do
      post :xhr_description
    end
    member do
      post :set_deliverable_description
      post :set_deliverable_filename
      post :set_deliverable_name
      post :set_deliverable_published      
    end
  end
  resources :deliverable_validations do
    member do
      post :update_deliverable
    end
  end
  resources :grades do
    collection do
      get :request_report, :request_missing, :reveal_mine
      post :for_user, :missing, :report
    end
    member do
      put :update_for_user
    end
  end
  resources :notices do
    member do
      post :dismiss
    end
  end
  resources :prerequisites do
    member do
      post :set_prerequisite_course_number
      post :set_prerequisite_waiver_question
    end
  end
  resources :profiles do
    collection do
      get :my_own
      post :websis_lookup
    end
  end    
  resources :sessions do
    collection do
      # TODO(costan): remove the "get" once Firefox Account Manager gets its bug
      #               fixed
      get :logout
      # TODO(costan): remove the "post" once Account manager can DELETE
      post :logout
    end
  end
  resources :student_infos do
    collection { get :my_own }
  end
  resources :submissions do
    member do
      get :file
      post :revalidate
    end
    collection do
      get :request_package
      post :package_assignment
      post :xhr_update_cutoff
      post :xhr_update_deliverables
    end
  end
  resources :survey_answers do
    collection { get :assignment_picker }
  end
  resources :surveys do
    member do
      post :add_question
      delete :remove_question
    end
  end
  namespace :system do
    root :to => 'system/health#stat_system'
    resources :processes, :controller => 'health'
  end  
  resources :teams do
    collection { get :my_own }
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
  root :to => "sessions#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  match 'tokens/:token', :to => 'tokens#spend', :as => :spend_token
end
