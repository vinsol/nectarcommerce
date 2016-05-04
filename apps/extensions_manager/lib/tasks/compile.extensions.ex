defmodule Mix.Tasks.Compile.Extensions do
  use Mix.Task
  @recursive true

  @moduledoc """
  Compiles Phoenix source files that support code reloading.
  """

  @doc false
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:nectar)
    case touch() do
      [] -> :noop
      _  -> :ok
    end
  end

  @doc false
  def touch do
    nectar_modules
    |> modules_for_recompilation
    |> modules_to_file_paths
    |> Stream.map(&touch_if_exists(&1))
    |> Stream.filter(&(&1 == :ok))
    |> Enum.to_list()
  end

  defp touch_if_exists(path) do
    # change the timestamp of file which wants a recompile
    :file.change_time(path, :calendar.local_time())
  end

  defp modules_for_recompilation(modules) do
    Stream.filter modules, fn mod ->
      Code.ensure_loaded?(mod) and
        function_exported?(mod, :__nectar_recompile__?, 0) and
        mod.__nectar_recompile__?
    end
  end

  defp modules_to_file_paths(modules) do
    Stream.map(modules, fn mod -> mod.__info__(:compile)[:source] end)
  end

  # find a better way than full build path scan
  defp nectar_modules do
    Mix.Project.build_path
    |> Path.join("*")
    |> Path.join("*")
    |> Path.join("*")
    |> Path.join("*.beam")
    |> Path.wildcard
    |> Enum.filter(&nectar_module/1)
    |> Enum.map(&beam_to_module/1)
  end

  defp beam_to_module(path) do
    path |> Path.basename(".beam") |> String.to_atom()
  end

  defp nectar_module(module_name) do
    module_name =~ "Nectar"
  end

end
