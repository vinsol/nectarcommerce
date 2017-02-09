defmodule Nectar.RouteExtender do
  defmacro __using__(_opts) do
    case Code.ensure_loaded(ExtensionsManager.Router) do
      {:module, module} -> mount_router(module)
      {:error, _reason} -> do_nothing()
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
