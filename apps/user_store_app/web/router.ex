defmodule UserStoreApp.Router do
  use UserStoreApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UserStoreApp do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end
  forward "/likes", FavoriteProductsPhoenix.Router
  # act as final catch all
  forward "/", Nectar.Router

  # Other scopes may use custom stacks.
  # scope "/api", UserStoreApp do
  #   pipe_through :api
  # end
end
