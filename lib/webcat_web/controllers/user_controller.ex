defmodule WebCATWeb.UserController do
  alias WebCATWeb.UserView

  use WebCATWeb, :authenticated_controller

  action_fallback(WebCAT.FallbackController)

  plug JSONAPI.QueryParser, filter: ~w(), sort: ~w(email first_name last_name)a, view: UserView

  def index(_conn, _user, _params) do
  end

end
