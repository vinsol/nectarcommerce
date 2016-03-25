defmodule FavoriteProductsPhoenix.Install do
  defmacro __using__([install: install_type]) do
    do_install(install_type)
  end

  defp do_install("router") do
    quote do
      define_route do
        forward "/", FavoriteProductsPhoenix.Router
      end
    end
  end

  defp do_install("products") do
    quote do
      add_to_schema(:has_many, :liked_by, through: [:likes, :user])
      add_to_schema(:has_many, :likes, FavoriteProducts.UserLike, [])
      include_method do

        def like_changeset(model, params \\ :empty) do
          model
          |> cast(params, ~w(), ~w())
          |> cast_assoc(:likes) # will be passed the user id here.
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
      add_to_schema(:has_many, :likes, FavoriteProducts.UserLike, [])
      include_method do

        def liked_products(model) do
          from like in assoc(model, :likes),
          preload: [:liked_products]
        end

      end
    end
  end
end
