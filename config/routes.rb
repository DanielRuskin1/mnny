Rails.application.routes.draw do
  root("static#index")

  get("/auth/:provider/callback", to: "sessions#create")
  post("/auth/:provider/callback", to: "sessions#create")

  get("/auth/failure", to: "sessions#failure")
  resources("sessions", only: []) do
    collection do
      delete(:destroy)
    end
  end

  resources("summary", only: [:index]) do
    collection do
      get(:get_chart_data)
    end
  end

  resources("accounts", only: [:index, :create, :destroy]) do
    member do
      get(:start_import)
      get(:import_complete)
    end
  end

  resources("balance_record_sets", only: [:show, :create, :destroy]) do
    member do
      post(:create_balance_record)
      delete(:destroy_balance_record)
    end
  end

  resources("settings", only: [:index]) do
    collection do
      put :edit
      get :export_data
    end
  end

  resources("help", only: [:index]) do
    collection do
      post :submit
    end
  end
end
