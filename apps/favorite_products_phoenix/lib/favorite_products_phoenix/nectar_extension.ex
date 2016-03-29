defmodule FavoriteProductsPhoenix.NectarExtension do
  defmacro __using__([install: install_type]) do
    do_install(install_type)
  end

  defp do_install("products") do
    quote do
      add_to_schema(:has_many, :liked_by, through: [:likes, :user])
      add_to_schema(:has_many, :likes, FavoriteProductsPhoenix.UserLike, [])
      include_method do
        def like_changeset(model, params \\ :empty) do
          model
          |> cast(params, ~w(), ~w(id))
          |> cast_assoc(:likes, required: true, with: &FavoriteProductsPhoenix.UserLike.changeset/2)
        end

        def liked_by(model) do
          from like in assoc(model, :likes),
          preload: [:liked_by]
        end
      end
    end
  end

  defp do_install("users") do
    quote do
      add_to_schema(:has_many, :liked_products, through: [:likes, :product])
      add_to_schema(:has_many, :likes, FavoriteProductsPhoenix.UserLike, [])
      include_method do
        def liked_products(model) do
          from like in assoc(model, :likes),
          preload: [:liked_products]
        end
      end
    end
  end

  defp do_install("router") do
    quote do
      define_route do
        scope "/favorites", FavoriteProductsPhoenix do
          # awareness about all pipelines declared in nectar required.
          pipe_through [:browser, :browser_auth] # Use the default browser stack
          resources "/", FavoriteController, only: [:index, :update]
        end
        scope "/admin", FavoriteProductsPhoenix.Admin do
          pipe_through [:browser, :admin_browser_auth]
          resources "/favorites", FavoriteController, only: [:index]
        end
      end
    end
  end
end
