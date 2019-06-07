JeopardyBot::Application.routes.draw do
  resources :tests

  get '/clue/random', to: 'clue#random'
end
