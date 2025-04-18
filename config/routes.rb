Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  mount GoodJob::Engine => "good_job"

  namespace :api do
    namespace :v1 do
      resources :events, only: [ :create ]
      resources :people, only: [ :create ]
    end
  end
end
