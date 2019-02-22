defmodule WebCATWeb.FallbackController do
  use WebCATWeb, :controller
  alias WebCATWeb.ErrorView

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(ErrorView, "error.html", error: "404", message: "Not Found", user: user_or_nil(conn), selected: nil)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> render(ErrorView, "error.html", error: "403", message: "Forbidden", user: user_or_nil(conn), selected: nil)
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(403)
    |> render(ErrorView, "error.html", error: "403", message: message, user: user_or_nil(conn), selected: nil)
  end

  defp user_or_nil(conn) do
    try do
      WebCATWeb.Auth.Guardian.Plug.current_resource(conn)
    rescue
      RuntimeError -> nil
    end
  end
end
