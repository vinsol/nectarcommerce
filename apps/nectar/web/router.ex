defmodule Nectar.Router do
  use Nectar.Web, :router

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

  pipeline :api_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :admin_browser_auth do
    plug Guardian.Plug.VerifySession, key: :admin
    plug Guardian.Plug.LoadResource, key: :admin
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", Nectar do

    pipe_through [:browser, :browser_auth] # Use the default browser stack

    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
    delete "/logout", SessionController, :logout

    resources "/orders", OrderController, only: [:index, :show]

  end

  # all actions where the user's cart is required go here.
  # note: if cart is not present it will create and link a new one.
  scope "/", Nectar do
    pipe_through [:browser, :browser_auth, Nectar.Plugs.Cart]
    get "/", ProductController, :index, as: :home

    get "/cart", CartController, :show
    put "/cart", CartController, :update

    resources "/products", ProductController, only: [:show, :index]
    resources "/line_items", LineItemController, only: [:create, :delete]
    get "/checkout",      CheckoutController, :checkout
    put "/checkout/next", CheckoutController, :next
    put "/checkout/back", CheckoutController, :back
    resources "/categories", CategoryController do
      get "/products", CategoryController, :associated_products, as: :products
    end
  end

  scope "/admin", Nectar.Admin, as: :admin do
    pipe_through [:browser, :admin_browser_auth]

    get "/", HomeController, :index
    resources "/countries", CountryController do
      resources "/states", StateController, only: [:create, :delete]
    end
    resources "/zones", ZoneController do
      resources "/members", ZoneMemberController, only: [:create, :delete]
    end

    resources "/cart", CartController, only: [:new, :edit, :create]

    resources "/categories", CategoryController

    resources "/orders", OrderController, only: [:index, :show, :update, :edit] do
      resources "/line_items", LineItemController, only: [:create, :delete] do
        put "/update_fullfillment", LineItemController, :update_fullfillment
      end
      get "/checkout", CheckoutController, :checkout
      put "/checkout/next", CheckoutController, :next
      put "/checkout/back", CheckoutController, :back
      resources "/payments", PaymentController, only: [:show] do
        put "/refund",  PaymentController, :refund,  as: :refund
        put "/capture", PaymentController, :capture, as: :capture
      end
    end

    resources "/users", UserController do
      get "/all_pending_orders", UserController, :all_pending_orders
    end

    resources "/settings", SettingController, only: [:edit, :update]
    get "/settings/payment", SettingController,  :payment_method_settings
    get "/settings/shipping", SettingController, :shipping_method_settings
    post "/settings/payment", SettingController,  :update_payment_method_settings
    post "/settings/shipping", SettingController, :update_shipping_method_settings

    get "/echo", ChannelEchoController, :echo
    post "/echo", ChannelEchoController, :do_echo


    resources "/sessions", SessionController, only: [:new, :create]
    delete "/logout", SessionController, :logout

    resources "/option_types", OptionTypeController

    resources "/products", ProductController do
      resources "/variants", VariantController
    end
    resources "/users", UserController
  end

  scope "/api", Nectar.Api do
    pipe_through [:api, :api_auth, Nectar.Plugs.Cart]
    get "/cart", CartController, :show
  end

  use Nectar.RouteExtender
  # Other scopes may use custom stacks.
  # scope "/api", Nectar do
  #   pipe_through :api
  # end
end
