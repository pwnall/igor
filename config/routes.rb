Seven::Application.routes.draw do
  authpwn_session

  # Registration
  resources :profiles, :only => [] do
    collection do
      post :websis_lookup
      put :websis_lookup
    end
  end
  resources :registrations
  resources :recitation_sections

  
  resources :analyses
  resources :survey_questions
  resources :team_memberships
  
  resources :users do
    collection do
      get :lookup
      post :check_email
    end
    member do
      post :impersonate
      put :set_admin
      put :confirm_email
    end
  end
  
  resources :announcements  
  resource :api, :controller => 'api' do
    get :conflict_info
  end
  resources :assignment_metrics
  resources :assignments
  resources :courses
  resources :deliverables do
    collection do
      post :xhr_description
    end
  end
  resources :analyzers do
    member do
      get :contents
      put :update_deliverable
    end
  end
  resources :grades do
    collection do
      get :editor
      get :request_report, :request_missing
      post :for_user, :missing, :report
    end
    member do
      put :update_for_user
    end
  end
  resources :prerequisites
  resources :profile_photos do
    member do
      get :profile, :thumb
    end
  end
  resources :submissions do
    member do
      get :file
      get :info
      post :revalidate
    end
    collection do
      get :request_package
      post :xhr_deliverables
      post :package_assignment
    end
  end
  resources :survey_answers
  resources :surveys do
    member do
      post :add_question
      delete :remove_question
    end
  end
  resources :team_partitions
  resources :teams

  root :to => "session#show"
end
