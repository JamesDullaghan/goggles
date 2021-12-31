Rails.application.routes.draw do
  root "documents#index"

  resources :documents
  resources :ocrs
  resources :uploads
end
