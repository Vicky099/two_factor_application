Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root "sessions#new"

  resources :homes do
  end

  resources :users do
  	collection do 
  		post :register
      put :update_two_factor
      get :get_token_to_activate_factor
      put :activate_factor
  	end
  end

  resources :sessions do 
  	collection do 
  		post :login
      get :two_factor
      post :verify_token
      get :verify_factor
      put :verify_factor_with_token
      get :resend_token
  	end

  	member do
  		delete :logout
  	end
  end
end
