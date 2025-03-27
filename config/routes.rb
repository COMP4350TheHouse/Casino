Rails.application.routes.draw do
  get "chat/send"
  get "chat/receive"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "lobby#index"
  get "/lobby", to: "lobby#index"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Defines the root path route ("/")

  resource :session

  resources :users

  get "/lobby", to: "lobby#index"
  post "/lobby/logout", to: "lobby#logout", as: :logout_lobby
  post "/lobby/horse_racing", to: "lobby#horse_racing", as: :horse_racing_lobby
  post "/lobby/roulette", to: "lobby#roulette", as: :roulette_lobby

  get "horse_race/index", to: "horse_race#index"
  post "/chat/send", to: "chat#send_message", as: 'send_message'

  get "roulette/roulette_board"

  post 'horse_race/restart_race', to: 'horse_race#restart_race', as: 'restart_race'
  post 'horse_race/submit_bet', to: 'horse_race#submit_bet', as: 'submit_bet'
  post 'roulette/submit_roulette_bet', to: 'roulette#submit_roulette_bet', as: 'submit_roulette_bet'
  post 'roulette/payout_bets', to: 'roulette#payout_bets', as: 'payout_bets'
  post 'roulette/placed_chips_request', to: 'roulette#placed_chips_request', as: 'placed_chips_request'
  get  'roulette/winning_num_request', to: 'roulette#winning_num_request', as: 'winning_num_request'
end
