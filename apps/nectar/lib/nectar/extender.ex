defmodule Nectar.Extender do
  defmacro __using__(_opts) do
    case extension_module(__CALLER__) do
      {:module, module} -> use_found_module(module)
      {:error, _reason} -> provide_no_op()
    end
  end

  def extension_module(caller) do
    module_to_extend = caller.module |> Module.split |> List.last
    module_name = String.to_atom("Elixir.ExtensionsManager.Extend" <> module_to_extend)
    Code.ensure_loaded(module_name)
  end

  def use_found_module(module) do
    quote do
      use unquote(module)
      def __nectar_recompile__?, do: true
    end
  end

  def provide_no_op do
    quote do
      import Nectar.Extender, only: [extensions: 0]
      def __nectar_recompile__?, do: true
    end
  end

  def extensions do
    # does nothing, just to pass the compilation
  end

end
