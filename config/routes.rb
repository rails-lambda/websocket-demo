Rails.application.routes.draw do
  post 'login', to: 'application#login'
  delete 'logout', to: 'application#logout'
  resources :rooms do
    resources :messages
  end
  root to: 'application#index'
end
