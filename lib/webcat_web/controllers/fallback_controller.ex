defmodule WebCATWeb.FallbackController do
  use WebCATWeb, :controller
  alias WebCATWeb.ErrorView

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("404.json")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(ErrorView)
    |> render("403.html")
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(400)
    |> put_view(ErrorView)
    |> render("400.json", %{message: message})
  end
end
