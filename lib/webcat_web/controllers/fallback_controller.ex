defmodule WebCATWeb.FallbackController do
  use WebCATWeb, :controller
  alias WebCATWeb.ErrorView

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("400.json", changeset: changeset)
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("400.json")
  end

  def call(conn, {:error, :bad_request, message}) when is_binary(message) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("400.json", message: message)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render("401.json")
  end

  def call(conn, {:error, :unauthorized, message}) when is_binary(message) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render("401.json", message: message)
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(ErrorView)
    |> render("403.json")
  end

  def call(conn, {:error, :forbidden, message}) when is_binary(message) do
    conn
    |> put_status(:forbidden)
    |> put_view(ErrorView)
    |> render("403.json", message: message)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("404.json")
  end

  def call(conn, {:error, :not_found, message}) when is_binary(message) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("404.json", message: message)
  end

  def call(conn, {:error, :server_error, message}) when is_binary(message) do
    conn
    |> put_status(:server_error)
    |> put_view(ErrorView)
    |> render("500.json", message: message)
  end

  def call(conn, _) do
    conn
    |> put_status(500)
    |> put_view(ErrorView)
    |> render("500.json")
  end
end
