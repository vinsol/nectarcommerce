defmodule FavoriteProducts do
  defmacro install(model) do
    do_install(model)
  end

  defp do_install("products") do
    quote do
      add_to_schema(:has_many, :liked_by, through: [:likes, :user])
      add_to_schema(:has_many, :likes, Nectar.Extensions.UserLike, [])
      include_method do
        quote do
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
  end

  defp do_install("users") do
    quote do
      add_to_schema(:has_many, :liked_products, through: [:likes, :product])
      add_to_schema(:has_many, :likes, Nectar.Extensions.UserLike, [])
      include_method do
        quote do
          def liked_products(model) do
            from like in assoc(model, :likes),
            preload: [:liked_products]
          end
        end
      end
    end
  end

  defp do_install("models") do
    quote do
      define_model do
        quote do
          IO.puts "starting defining modules"
          defmodule UserLike do
            IO.puts "defining userlikes #{__MODULE__}"
	          use Nectar.Web, :model

            schema "user_likes" do
              belongs_to :user, Nectar.User
              belongs_to :product, Nectar.Product
            end

            def changeset(model, params \\ :empty) do
              model
              |> cast(params, ~w(), ~w(user_id product_id))
            end
          end
        end
      end
    end
  end

end
