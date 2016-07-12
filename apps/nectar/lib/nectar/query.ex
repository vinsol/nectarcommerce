defmodule Nectar.Query do
  defmacro __using__([model: model]) do
    model = Macro.expand(model, __ENV__)
    quote location: :keep do
      import Ecto.Query

      defp by_id(id) do
        from m in unquote(model),
          where: m.id == ^id
      end

      def get(repo, id) do
        repo.get(unquote(model), id)
      end

      def get!(repo, id) do
        repo.get!(unquote(model), id)
      end

      def all(repo) do
        repo.all(unquote(model))
      end

      def get_by(repo, params) do
        repo.get_by(unquote(model), params)
      end

      def get_by!(repo, params) do
        repo.get_by!(unquote(model), params)
      end

    end
  end
end
