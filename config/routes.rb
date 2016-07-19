Rails.application.routes.draw do
  root 'wallet#index'

  devise_for :users

  post 'wallet/create'
  get 'wallet/index'
  get 'wallet/new'
  get 'wallet/show'
  post 'wallet/update'
  get 'wallet/redeem'
  post 'wallet/get_response'
  get 'wallet/enquiry'
  get 'wallet/refund'
  post 'wallet/get_refund'

  get 'mvc/index'
  get 'mvc/authenticate'
  post 'mvc/create'
  post 'mvc/issue_coupon'
  post 'mvc/rollback_coupon'
  post 'mvc/fetch_one_mvc'
  get 'mvc/fetch_all_mvc'
  post 'mvc/fetch_balance'
  post 'mvc/fetch_all_balance'
  post 'mvc/redeem_coupon'
  post 'mvc/fetch_coupons'
  post 'mvc/deactivate_mvc'
  post 'mvc/fetch_transactions'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
