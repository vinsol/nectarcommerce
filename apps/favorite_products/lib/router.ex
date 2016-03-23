defmodule FavoriteProducts.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  scope "/", FavoriteProducts do

    pipe_through [:browser, :browser_auth] # Use the default browser stack

    resources "/likes", FavoriteController, only: [:index]
  end
end
