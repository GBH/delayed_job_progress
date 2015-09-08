DelayedJobProgress::Engine.routes.draw do
  resources :jobs do
    post :reload, :on => :member
  end
end
