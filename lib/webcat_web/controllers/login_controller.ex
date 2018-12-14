defmodule WebCATWeb.LoginController do
  @moduledoc """
  Handle authentication tasks
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, params) do
    render(conn, "login.html",
      redirect: Map.get(params, "redirect", Routes.index_path(conn, :index))
    )
  end

  def login(conn, params) do
    case params do
      %{"email" => email, "password" => password} ->
        with {:ok, user} <- Users.login(email, password) do
          conn
          |> Auth.sign_in(user)
          |> redirect(to: Map.get(params, "redirect", Routes.index_path(conn, :index)))
        else
          {:error, _} ->
            conn
            |> put_flash(:error, "invalid email or password")
            |> redirect(to: Routes.login_path(conn, :login))

          _ ->
            conn
            |> put_flash(:error, "unknown error")
            |> redirect(to: Routes.login_path(conn, :login))
        end

      _ ->
        conn
        |> put_flash(:error, "unknown error")
        |> redirect(to: Routes.login_path(conn, :login))
    end
  end

  def logout(conn, _params) do
    conn
    |> Auth.sign_out()
    |> redirect(to: Routes.login_path(conn, :login))
  end
end
