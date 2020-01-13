Rails.application.routes.draw do
  get "article", to: "home#article"
  
  root to: "home#index"
end
