defmodule ExtensionModels do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :module_blocks, accumulate: true)
      import ExtensionModels, only: [define_model: 1]
      @before_compile ExtensionModels

      defmacro __using__(_opts) do
        quote do
          import unquote(__MODULE__), only: [include_models: 0]
          @before_compile unquote(__MODULE__)
        end
      end

      defmacro __before_compile__(_env) do
        quote do
          include_models
        end
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defmacro include_models do
        quote do
          unquote(Enum.map(module_blocks, fn (module_block) -> module_block end))
        end
      end
      def module_blocks do
        @module_blocks
      end
    end
  end

  defmacro define_model([do: block]) do
    quote bind_quoted: [block: block] do
      Module.put_attribute(__MODULE__, :module_blocks, block)
    end
  end
end
