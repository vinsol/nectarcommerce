defmodule NectarCore.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use NectarCore.Web, :controller
      use NectarCore.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      alias  unquote(repo_to_alias)

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller
      alias  unquote(repo_to_alias)
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

      import NectarCore.Router.Helpers
      import NectarCore.Gettext
      alias  unquote(router_to_alias).Helpers, as: NectarRoutes
    end
  end

  def admin_controller do
    quote do
      use Phoenix.Controller

      alias  unquote(repo_to_alias)
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

      import NectarCore.Router.Helpers
      import NectarCore.Gettext
      alias  unquote(router_to_alias).Helpers, as: NectarRoutes
    end
  end

  def view do
    quote do
      import unquote(__MODULE__), only: [template_root_folder: 1]
      use Phoenix.View, root: template_root_folder(__MODULE__)

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import NectarCore.Router.Helpers
      import NectarCore.ErrorHelpers
      import NectarCore.Gettext
      alias  unquote(router_to_alias).Helpers, as: NectarRoutes
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias unquote(repo_to_alias)
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
      import NectarCore.Gettext
    end
  end

  # will look for the configured router and repo, if none found will
  # assume Nectar is the main project to use
  def repo_to_alias do
    Application.get_env(:nectar_core, :repo, Nectar.Repo)
  end

  @priority_root "../templates/"
  @default_root "lib/web/templates"
  def template_root_folder(module) do
    namespace =
      module
      |> Module.split
      |> Enum.take(1)
      |> Module.concat

    priority_path =
      Path.join(@priority_root, Phoenix.Template.module_to_template_root(module, namespace, "View"))

    if File.exists? priority_path do
      @priority_root
    else
      @default_root
    end
  end

  def router_to_alias do
    Application.get_env(:nectar_core, :router, Nectar.Router)
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
