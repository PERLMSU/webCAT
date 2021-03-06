defmodule WebCATWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use WebCATWeb, :controller
      use WebCATWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: WebCATWeb
      import Plug.Conn
      import WebCATWeb.Gettext
      alias WebCATWeb.Router.Helpers, as: Routes
      alias WebCATWeb.Auth.Guardian.Plug, as: Auth
    end
  end

  def authenticated_controller do
    quote do
      use WebCATWeb, :controller
      use Terminator

      # Override Phoenix.Controller.action/2 callback
      def action(conn, _) do
        user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)
        load_and_authorize_performer(user)

        apply(__MODULE__, action_name(conn), [conn, user, conn.params])
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/webcat_web/templates",
        namespace: WebCATWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      alias WebCATWeb.Router.Helpers, as: Routes
      import WebCATWeb.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import WebCATWeb.RouterHelpers
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import WebCATWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
