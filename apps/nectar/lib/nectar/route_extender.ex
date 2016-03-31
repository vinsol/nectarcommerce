defmodule Nectar.RouteExtender do
  defmacro __using__(opts) do
<<<<<<< HEAD
    case Code.ensure_loaded(ExtensionsManager.Router) do
=======
    case Code.ensure_loaded(ExtensionsManager.ExtensionsRouter) do
>>>>>>> 4bafcf2... Updated Nectar.Extender and Nectar.RouteExtender to use namespaced ExtensionsManager name
      {:module, module} -> mount_router(module)
      {:error, _reason} -> do_nothing
    end
  end

  def mount_router(module) do
    quote do
      require unquote(module)
      unquote(module).mount
    end
  end
  def do_nothing do
    quote do
    end
  end
end
