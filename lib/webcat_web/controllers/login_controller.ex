defmodule WebCATWeb.LoginController do
  @moduledoc """
  Handle authentication tasks
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users

  def index(conn, _params) do
    render(conn, "login.html")
  end

  def login(conn, params) do
    case params do
      %{"email" => email, "password" => password} ->
        IO.inspect(params)
        with {:ok, user} <- Users.login(email, password) do
          conn
          |> WebCATWeb.Auth.Guardian.Plug.sign_in(user)
          |> redirect(to: dashboard_path(conn, :index))
        else
          {:error, _} ->
            conn
            |> put_flash(:error, "invalid email or password")
            |> redirect(to: login_path(conn, :login))
          _ ->
            conn
            |> put_flash(:error, "unknown error")
            |> redirect(to: login_path(conn, :login))
        end

      _ ->
        conn
        |> put_flash(:error, "unknown error")
        |> redirect(to: login_path(conn, :login))
    end
  end
end
