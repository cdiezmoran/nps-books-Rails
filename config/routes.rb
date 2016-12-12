Rails.application.routes.draw do
  resources :books, only: [:index]
  root to: "books#index"
  match '/books/:isbn' => 'books#show', :as => 'books_show', via: [:get]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
