Seven::Application.routes.draw do
  root 'session#show'

  # Site-wide functionality.
  scope '_' do
    authpwn_session
    resources :courses, only: [:index, :new, :create] do
      collection do
        get :connect
      end
    end

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
        patch :websis_lookup
      end
    end
    resources :profile_photos do
      member do
        get :profile, :thumb
      end
    end

    # Staff registration.
    resources :roles, only: [:destroy]

    # Exception handling test.
    get '/crash' => 'crash#show'
  end

  # Course-specific URLs. Most functionality falls here.
  scope ':id', constraints: { id: /[^\/]+/ } do
    get 'course(.:format)', to: 'courses#show', as: :course
    patch 'course(.:format)', to: 'courses#update'
    delete 'course(.:format)', to: 'courses#destroy'
    get 'course/edit(.:format)', to: 'courses#edit', as: :edit_course
  end

  scope ':course_id', constraints: { course_id: /[^\/]+/ } do
    get '/', to: 'session#show', as: :course_root

    resources :prerequisites, except: [:show]
    resources :time_slots, only: [:index, :create, :destroy]

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

    # Recitations.
    resources :recitation_sections, except: [:show] do
      collection do
        post :autoassign
      end
    end
    resources :recitation_partitions, only: [:index, :show, :destroy]  do
      member do
        post :implement
      end
    end

    # Homework.
    resources :assignments do
      member do
        get :dashboard
      end
    end
    resources :assignment_files, only: [] do
      member do
        get :download
      end
    end
    resources :grades, only: [:index, :create] do
      collection do
        get :editor
        get :request_report, :request_missing
        post :for_user, :missing, :report
      end
    end
    resources :grade_comments, only: [:create]

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
    resources :submissions, only: [:index, :create, :destroy] do
      member do
        get :file
        get :info
        post :reanalyze
        post :promote
      end
      collection do
        get :request_package
        post :xhr_deliverables
        post :package_assignment
      end
      resources :collaborations, only: [:create, :destroy], shallow: true
    end
    resources :analyses, only: [:show]

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
    resources :team_partitions do
      member do
        patch :lock
        patch :unlock
        get :issues
      end
    end

    resources :teams, only: [:edit, :create, :update, :destroy]
    # Teams / Student view.
    get '/teams_student', to: 'teams_student#show'
    post '/teams_student/leave_team', to: 'teams_student#leave_team', as: :leave_team
    post '/teams_student/create_team', to: 'teams_student#create_team'
    post '/teams_student/invite_member', to: 'teams_student#invite_member'
    post '/teams_student/accept_invitation', to: 'teams_student#accept_invitation'
    post '/teams_student/ignore_invitation', to: 'teams_student#ignore_invitation'
    resources :teams_student

    # Deprecated.
    resources :announcements
  end
end
