Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'events#index'

  resources :events, only: [ :show, :update ] do
    get :archived, on: :collection
    get :retry, on: :member
    post :archive, on: :collection
  end
end
