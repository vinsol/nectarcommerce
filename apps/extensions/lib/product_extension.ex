defmodule Extension do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :schema, accumulate: true)

      import Extension, only: [add_to_schema: 4]
      @before_compile Extension

      defmacro __using__(opts) do
        quote do
          import unquote(__MODULE__), only: [extensions: 0, schema_changes: 0]
        end
      end
    end
  end

  defmacro add_to_schema(method, name, type, options) do
    quote bind_quoted: [name: name, type: type, options: options, method: method], location: :keep do
      Module.put_attribute(__MODULE__, :schema, {method, name, type, options})
    end
  end

  defmacro __before_compile__(env) do
    quote do
      defmacro extensions do
        quote do
          Enum.map(schema_changes, fn
            ({:field, name, type, options}) -> field name, type, options
          end)
        end
      end

      def schema_changes do
        @schema
      end
    end
  end
end

defmodule ExtendProduct do
  use Extension

  add_to_schema(:field, :not_real, :boolean, virtual: true, default: false)

end
