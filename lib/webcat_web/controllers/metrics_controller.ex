defmodule WebCATWeb.MetricsController do
  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _assigns) do
    conn
    |> put_status(:ok)
    |> json(%{status: "healthy"})
  end
end
