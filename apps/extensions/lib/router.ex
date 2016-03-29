defmodule RouterExtension do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :defined_routes, accumulate: true)

      import RouterExtension, only: [define_route: 1]
      @before_compile RouterExtension
    end
  end

  defmacro define_route([do: rt]) do
    block = Macro.escape(rt)
    quote bind_quoted: [block: block] do
      Module.put_attribute(__MODULE__, :defined_routes, block)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defmacro mount do
        @defined_routes
      end
    end
  end
end
