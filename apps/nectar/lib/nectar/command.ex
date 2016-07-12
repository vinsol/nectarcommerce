defmodule Nectar.Command do
  defmacro __using__([model: model]) do
    model = Macro.expand(model, __ENV__)

    quote location: :keep do
      def insert!(repo, params) do
        unquote(model).changeset(struct(unquote(model)), params)
        |> repo.insert!
      end

      def update!(repo, existing, params) do
        unquote(model).changeset(existing, params)
        |> repo.update!
      end

      def delete_all(repo) do
        repo.delete_all(unquote(model))
      end

      def insert(repo, params) do
        unquote(model).changeset(struct(unquote(model)), params)
        |> repo.insert
      end

      def delete!(repo, existing) do
        repo.delete!(existing)
      end

      def update(repo, existing, params) do
        unquote(model).changeset(existing, params)
        |> repo.update
      end

      defoverridable [insert!: 2, update!: 3, delete_all: 1, insert: 2, update: 3, delete!: 2]
    end
  end
end
