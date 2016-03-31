defmodule FavoriteProducts.NectarExtension do
  defmacro __using__([install: install_type]) do
    do_install(install_type)
  end

  defp do_install("router") do
    quote do
      define_route do
        scope "/", FavoriteProducts do
          ## Do not forget to add the pipelines request should go through
          pipe_through [:browser, :browser_auth]
          resources "/favorites", FavoriteController, only: [:index, :create, :delete]
        end
      end
    end
  end

  defp do_install("products") do
    quote do
      ## In Phoenix App Model Schema definition, join association is defined first and then through association
      ## Please note the reverse order here as while collecting, it gets the reverse order and
      ## injected into actual model schema as expected .. tricky huhh !!
      add_to_schema(:has_many, :liked_by, through: [:likes, :user])
      add_to_schema(:has_many, :likes, FavoriteProducts.UserLike, [])
      include_method do

        def like_changeset(model, params \\ :empty) do
          model
          |> cast(params, ~w(), ~w())
          |> cast_assoc(:likes) # will be passed the user id here.
        end

        def liked_by(model) do
          from like in assoc(model, :liked_by)
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
          from like in assoc(model, :liked_products)
        end
      end
    end
  end
end
