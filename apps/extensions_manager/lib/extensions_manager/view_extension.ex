defmodule ExtensionsManager.ViewExtension do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :partials, accumulate: true)

      import ExtensionsManager.ViewExtension, only: [provide_partial: 2]
      @before_compile ExtensionsManager.ViewExtension

      defmacro __using__(_opts) do
        quote do
          import unquote(__MODULE__), only: [setup_extensions_partials: 0, extensions_partials: 0]
          @before_compile unquote(__MODULE__)
        end
      end

      defmacro __before_compile__(_env) do
        quote do
          setup_extensions_partials
        end
      end
    end
  end

  defmacro provide_partial(module_name, template_name) do
    quote do
      Module.put_attribute(__MODULE__, :partials, {unquote(module_name), unquote(template_name)})
    end
  end

  defmacro __before_compile__(_env) do
    quote do

      defmacro setup_extensions_partials do
        Enum.map(extensions_partials, fn ({module, template_name}) ->
          quote do
            def render(unquote(template_name), assigns) do
              unquote(module).render(unquote(template_name), assigns)
            end
          end
        end)
      end

      def extensions_partials do
        @partials
      end

    end
  end
end
