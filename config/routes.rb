# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users, only: %i[new create destroy]

  get '/memos/search', to: 'memos#index'
  # get '/memos/export', to: 'memos#export'
  # post '/memos/search/tag', to: 'memos#search_with_tag'
  resources :memos

  get '/ytsearch', to: 'cmntsrch#index'
  get '/ytsearch/search', to: 'cmntsrch#search'
  get '/ytsearch/comments', to: 'cmntsrch#comments'
  # resources :cmntsrch
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
