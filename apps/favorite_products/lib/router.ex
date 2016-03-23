defmodule FavoriteProducts.Router do
  defmacro __using__(_opts) do
    quote do
      import FavoriteProducts.Router, only: [mount: 0]
    end
  end

  defmacro mount do
    quote do
      resources "/likes", FavoriteProducts.FavoriteController, only: [:index]
    end
  end
end
