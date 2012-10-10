Seven::Application.routes.draw do
  authpwn_session

  resources :courses
  resources :prerequisites

  # Registration
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
  resources :registrations
  resources :recitation_sections

  # Homework.
  resources :assignments do
    member do
      get :dashboard
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

  # Deprecated.
  resources :announcements
  resource :api, controller: 'api' do
    get :conflict_info
  end

  root to: 'session#show'
end
