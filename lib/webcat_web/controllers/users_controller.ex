defmodule WebCATWeb.UsersController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "users.html")
  end
end

