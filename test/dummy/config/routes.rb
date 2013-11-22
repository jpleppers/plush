Rails.application.routes.draw do
  root to: 'pages#show', via: 'get'

  resources :tags do
    collection do
      get 'search'
    end
  end

end
