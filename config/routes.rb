Rails.application.routes.draw do
 
  root 'pages#home'
  get 'home' => 'pages#home'
  get 'gen' => 'generator#gen'
  post 'gen' => 'generator#generate'
  get 'demandDistrib' => "pages#demandDistrib"
  #get 'generate' => 'generator#generatedData'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
