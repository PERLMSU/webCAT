defmodule WebCATWeb.UserController do
  alias WebCATWeb.UserView

  use WebCATWeb, :authenticated_controller

  action_fallback(WebCAT.FallbackController)

  def index(_conn, _user, _params) do
  end

end
