Rails.application.routes.draw do
  root 'wallet#index'

  devise_for :users

  post 'wallet/create'
  get 'wallet/index'
  get 'wallet/new'
  get 'wallet/show'
  post 'wallet/update'
  get 'wallet/redeem'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
