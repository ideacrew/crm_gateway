Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'events#index'

  resources :events, only: [ :show ] do
    get :retry, on: :member
    get :archive, on: :member
  end
end