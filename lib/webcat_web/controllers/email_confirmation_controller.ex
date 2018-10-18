defmodule WebCATWeb.EmailConfirmationController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  def confirm(conn, %{"token" => token}) do
    render(conn, "index.html")
  end
end

