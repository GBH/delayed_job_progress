DelayedJobProgress::Engine.routes.draw do
  resources :jobs do
    member do
      post :reload
      get :download
    end
  end
end
