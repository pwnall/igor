Seven::Application.routes.draw do
  root 'session#show'

  authpwn_session

  resources :courses
  resources :prerequisites

  # Account registration.
  resources :users do
    collection do
      post :check_email
    end
    member do
      post :impersonate
      put :set_admin
      put :confirm_email
    end
  end
  resources :profiles, only: [] do
    collection do
      post :websis_lookup
      put :websis_lookup
    end
  end
  resources :profile_photos do
    member do
      get :profile, :thumb
    end
  end

  # Student registration.
  resources :registrations,
            only: [:index, :show, :new, :create, :edit, :update] do
    member do
      patch :restricted
    end
  end

  # Staff registration.
  resources :role_requests, only: [:index, :new, :create, :show, :destroy] do
    member do
      post :approve
      post :deny
    end
  end
  resources :roles, only: [:destroy]

  resources :recitation_sections, except: [:show] do
    collection do
      post :autoassign
    end
  end


  # Homework.
  resources :assignments do
    member do
      get :dashboard
    end
  end
  resources :grades, only: [:index, :create] do
    collection do
      get :editor
      get :request_report, :request_missing
      post :for_user, :missing, :report
    end
  end

  # Homework submission.
  resources :analyzers, only: [] do
    collection do
      get :help
    end
    member do
      get :source
    end
  end
  resources :deliverables do
    member do
      get :submission_dashboard
      post :reanalyze
    end
  end
  resources :assignment_metrics
  resources :submissions do
    member do
      get :file
      get :info
      post :reanalyze
    end
    collection do
      get :request_package
      post :xhr_deliverables
      post :package_assignment
    end
  end
  resources :analyses

  # Surveys.
  resources :survey_questions
  resources :surveys do
    member do
      post :add_question
      delete :remove_question
    end
  end
  resources :survey_answers

  # Teams.
  resources :team_memberships, only: [:create, :destroy]
  resources :team_partitions
  resources :teams, only: [:edit, :create, :update, :destroy]
  # Teams / Student view.
  get '/teams_student' => 'teams_student#show'
  post '/teams_student/leave_team' => 'teams_student#leave_team', as: :leave_team
  post '/teams_student/create_team' => 'teams_student#create_team'
  post '/teams_student/invite_member' => 'teams_student#invite_member'
  post '/teams_student/accept_invitation' => 'teams_student#accept_invitation'
  post '/teams_student/ignore_invitation' => 'teams_student#ignore_invitation'
  post '/team_partitions/unlock/:id' => 'team_partitions#unlock'
  post '/team_partitions/lock/:id' => 'team_partitions#lock'
  get '/team_partitions/view_problem/:id' => 'team_partitions#view_problem', as: :view_problem_partition
  resources :teams_student

  # Exception handling test.
  get '/crash/crash' => 'crash#crash'

  # Deprecated.
  resources :announcements
  resource :api, controller: 'api' do
    get :conflict_info
  end

  # Recitation Proposals
  resources :recitation_partitions do
    member do
      post :implement
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
