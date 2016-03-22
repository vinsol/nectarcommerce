defmodule Extension do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
      Module.register_attribute(__MODULE__, :method_block, accumulate: true)

      import Extension, only: [add_to_schema: 4, include_method: 1]
      @before_compile Extension

      defmacro __using__(opts) do
        quote do
          import unquote(__MODULE__), only: [extensions: 0, schema_changes: 0, include_methods: 0, method_blocks: 0]
          IO.puts "imported #{unquote(__MODULE__)} into #{__MODULE__}"
          @before_compile unquote(__MODULE__)
        end
      end

      defmacro __before_compile__(env) do
        quote do
          include_methods
        end
      end
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

  defmacro __before_compile__(env) do
    quote do
      defmacro extensions do
        quote do
          Enum.map(schema_changes, fn
            ({:field, name, type, options}) -> field name, type, options
            ({:has_one, name, type, options}) -> has_one name, type, options
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

defmodule ExtendProduct do
  use Extension

  add_to_schema(:field, :not_real, :boolean, virtual: true, default: false)
  add_to_schema(:has_one, :variant, Nectar.Variant, [])

  include_method do
    quote do
      def is_real(%Nectar.Product{not_real: not_real}), do: not_real
      def has_master_variant?(%Nectar.Product{master: master}), do: true
      def has_master_variant?(%Nectar.Product{}), do: false
    end
  end

  include_method do
    quote do
      def is_real_2(%{not_real: not_real}), do: not_real
    end
  end

end

# use if nothing is available
defmodule ExtendVariant do
  use Extension
end
