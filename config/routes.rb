Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :carts do
        member do
          post :add_item
          delete :remove_item
        end
      end
    end
  end
end
