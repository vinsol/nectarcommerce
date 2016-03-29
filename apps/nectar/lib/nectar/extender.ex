defmodule Nectar.Extender do
  defmacro __using__(opts) do
    case extension_module(__CALLER__) do
      {:found, module} -> use_found_module(module)
      {:not_found} -> provide_no_op
    end
  end

  def extension_module(caller) do
    module_to_extend = caller.module |> Module.split |> List.last
    module_name = String.to_atom("Elixir.Extend" <> module_to_extend)
    IO.inspect "searching for #{module_name}"
    IO.inspect  Code.ensure_loaded(module_name)
    if Code.ensure_loaded?(module_name) do
      {:found, module_name}
    else
      {:not_found}
    end
  end

  def use_found_module(module) do
    quote do
      use unquote(module)
    end
  end

  def provide_no_op do
    quote do
      import Nectar.Extender, only: [extensions: 0]
    end
  end

  def extensions do
    # does nothing, just to pass the compilation
  end
end
