defmodule NectarWallet.Router do
  use NectarWallet.Web, :router

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

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  scope "/wallet", NectarWallet do
    pipe_through [:browser, :browser_auth] # Use the default browser stack
    get "/", WalletController, :edit
    put "/", WalletController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", NectarWallet do
  #   pipe_through :api
  # end
end
