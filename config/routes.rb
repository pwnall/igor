Seven::Application.routes.draw do
  resources :analyses

  authpwn_session
  
  resources :analysiss
  resources :survey_questions
  resources :team_memberships
  
  resources :users do
    collection do
      get :lookup
      post :check_email
    end
    member do
      get :edit_password
      post :impersonate
      put :set_admin
      put :update_password
    end
  end
  
  resources :announcements  
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
  resources :prerequisites do
    member do
      post :set_prerequisite_course_number
      post :set_prerequisite_waiver_question
    end
  end
  resources :profile_photos do
    member do
      get :profile, :thumb
    end
  end
  resources :profiles do
    collection do
      post :websis_lookup
    end
  end
  resources :recitation_sections do
    member do
      post :set_recitation_section_leader_id
      post :set_recitation_section_location
      post :set_recitation_section_serial
      post :set_recitation_section_time
    end
  end
  resources :registrations
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
  resources :survey_answers
  resources :surveys do
    member do
      post :add_question
      delete :remove_question
    end
  end
  resources :team_partitions
  resources :teams do
    member do
      post :set_team_name
    end
  end

  root :to => "session#show"
end
