defmodule Extension do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
      Module.register_attribute(__MODULE__, :method_block, accumulate: true)

      import Extension, only: [add_to_schema: 4, add_to_schema: 3, include_method: 1]
      @before_compile Extension

      defmacro __using__(_opts) do
        quote do
          import unquote(__MODULE__), only: [extensions: 0, schema_changes: 0, include_methods: 0, method_blocks: 0]
          @before_compile unquote(__MODULE__)
        end
      end

      defmacro __before_compile__(_env) do
        quote do
          include_methods
        end
      end
    end
  end

  defmacro add_to_schema(method, name, through) do
    quote bind_quoted: [name: name, through: through, method: method], location: :keep do
      Module.put_attribute(__MODULE__, :schema_changes, {method, name, through})
    end
  end
  defmacro add_to_schema(method, name, type, options) do
    quote bind_quoted: [name: name, type: type, options: options, method: method], location: :keep do
      Module.put_attribute(__MODULE__, :schema_changes, {method, name, type, options})
    end
  end

  defmacro include_method([do: block]) do
    quote bind_quoted: [block: block] do
      Module.put_attribute(__MODULE__, :method_block, block)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defmacro extensions do
        quote do
          Enum.map(schema_changes, fn
            ({:field, name, type, options}) -> field name, type, options
            ({:has_one, name, type, options}) -> has_one name, type, options
            ({:has_many, name, type, options}) -> has_many name, type, options
            ({:has_many, name, through}) -> has_many name, through
          end)
        end
      end

      def schema_changes do
        @schema_changes
      end

      defmacro include_methods do
        quote do
          unquote(Enum.map(method_blocks, fn (method_block) -> method_block end))
        end
      end

      def method_blocks do
        @method_block
      end
    end
  end
end

defmodule DefaultExtend do
  use Extension
end
