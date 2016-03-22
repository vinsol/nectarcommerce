defmodule DeletedProducts do
  defmacro __using__([install: install_type]) do
    do_install(install_type)
  end

  defp do_install("products") do
    quote do
      add_to_schema(:field, :deleted, :boolean, default: false)
      add_to_schema(:belongs_to, :deleted_by, Nectar.User, [])

      include_method do

        def mark_as_deleted_changeset(model, params) do
          model
          |> cast(params, ~w(deleted), ~w(deleted_by_id))
        end

        def deleted_products do
          from k in __MODULE__, where: k.deleted
        end

      end

    end
  end
end
