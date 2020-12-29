Rails.application.routes.draw do

  root 'sessions#welcome'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/dashboard', to: 'sessions#dashboard'

  get '/matchups/join', to: 'matchups#join'
  post '/matchups/join', to: 'matchups#confirm', as: 'matchup_confirm'
  post '/matchups/confirm', to: 'matchups#link_user', as: 'link_user_matchup'
  delete '/matchups/:matchup_id/:id', to: 'matchups#remove_user_matchup', as: 'remove_user_matchup'

  resources :matchups do 
    resources :invitations, only: [:new, :create, :destroy]
    get '/draft/start', to: 'matchups#start_draft', as: 'start_draft'
    get '/draft-table', to: 'draft#draft_table', as: 'draft_table'
  end

end
