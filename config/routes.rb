Rails.application.routes.draw do

  root 'sessions#welcome'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/dashboard', to: 'sessions#dashboard'

  get '/auth/failure', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post] 

  get '/usermatchups/new', to: 'user_matchups#new', as: 'new_user_matchup'
  post '/usermatchups/confirm', to: 'user_matchups#confirm', as: 'confirm_user_matchup'

  resources :matchups do 
    resources :invitations, only: [:new, :create, :edit, :update, :destroy]
    get '/draft/start', to: 'matchups#start_draft', as: 'start_draft'
    get '/draft-table', to: 'draft#draft_table', as: 'draft_table'
    resources :picks, only: [:create]
    resources :user_matchups, only: [:show, :create, :edit, :update, :destroy]
  end

end
