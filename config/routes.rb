Rails.application.routes.draw do
  get '/list', to: 'api/v2/stocks#list'
  post '/create', to: 'api/v2/stocks#create'
  put '/update', to: 'api/v2/stocks#update'
  delete '/delete/:id', to: 'api/v2/stocks#delete'
end
