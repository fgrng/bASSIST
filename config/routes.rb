Bassist::Application.routes.draw do

  root :controller => :sessions, :action => :new

  resources :sessions, only: [:new, :create, :destroy]
  match '/signup', :controller => :users, :action => :new, :via => 'get'
  match '/signin', :controller => :sessions, :action => :new, :via => 'get'
  match '/signout', :controller => :sessions, :action => :destroy, :via => 'delete'

  resources :users
  resources :password_resets, except: [:index, :destroy]
  resources :email_validations, only: [:show]

  resources :lectures, shallow: true do
    resources :students, :controller => :roles, :type => Role::TYPE_STUDENT, except: [:show]
    resources :tutors, :controller => :roles, :type => Role::TYPE_TUTOR, except: [:show]
    resources :teachers, :controller => :roles, :type => Role::TYPE_TEACHER, except: [:show]
    resources :subjects
    resources :tutorials
    member do
      get 'clear_tutorials'
      get 'fill_tutorials'
      get 'refill_tutorials'
      get 'force_fill_tutorials'
      get 'force_refill_tutorials'
      #
      get 'assign_tutorials'
      get 'deassign_tutorials'
      #
      get 'add_group'
      get 'remove_group'
      get 'fill_groups'
      get 'clear_groups'
      #
      get 'export_subjects'
      get 'export_students'
    end
  end

  resources :students, :controller => :roles, :type => Role::TYPE_STUDENT, only: [] do
    get 'toggle_validation', :on => :member
    resources :submissions, only: [:index]
    resources :exercises, only: [] do
      get 'create_empty_sub', :on => :member
    end
  end

  resources :users, only: [] do
    resources :lectures, only: [] do
      get 'add', :on => :member
    end
    member do
      get 'send_email_validation'
    end
  end

  resources :tutorials, only: [] do
    resources :students, :controller => :roles, :type => Role::TYPE_STUDENT, only: [:index] do
      get 'assign', :on => :member
    end
    resources :tutors, :controller => :roles, :type => Role::TYPE_TUTOR, only: [] do
      get 'assign', :on => :member
    end
  end

  resources :subjects, only: [], shallow: true do
    resources :exercises, only: [:index]
    resources :statements, :controller => :exercises, :type => Exercise::TYPE_STATEMENT_BASE
    resources :a_statements, :controller => :exercises, :type => Exercise::TYPE_STATEMENT_A
    resources :b_statements, :controller => :exercises, :type => Exercise::TYPE_STATEMENT_B
    resources :c_statements, :controller => :exercises, :type => Exercise::TYPE_STATEMENT_C
    resources :reflections, :controller => :exercises, :type => Exercise::TYPE_REFLECTION_BASE
    resources :a_reflections, :controller => :exercises, :type => Exercise::TYPE_REFLECTION_A
    resources :b_reflections, :controller => :exercises, :type => Exercise::TYPE_REFLECTION_B
    resources :c_reflections, :controller => :exercises, :type => Exercise::TYPE_REFLECTION_C
  end

  resources :exercises, only: [:show], shallow: true do
    resources :submissions do
      get 'missing', :on => :collection
      get 'external', :on => :collection
    end
    get 'count_submissions', :on => :member
    get 'create_extra_sub', :on => :member
  end

  resources :submissions, only: [], shallow: true do
    resources :feedbacks
  end

  resources :feedbacks, only: [] do
    get 'toggle_public', :on => :member
  end

  get "password_resets/new"

end
