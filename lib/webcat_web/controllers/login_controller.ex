defmodule WebCATWeb.LoginController do
  @moduledoc """
  Handle authentication tasks
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, params) do
    redirect = Map.get(params, "redirect", Routes.index_path(conn, :index))

    conn
    |> put_layout({WebCATWeb.LayoutView, "public.html"})
    |> render("login.html", redirect: redirect)
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
