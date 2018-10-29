defmodule WebCATWeb.PasswordResetController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.PasswordResets

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"email" => email}) do
    PasswordResets.start_reset(email)

    conn
    |> put_flash(:info, "Password reset sent!")
    |> redirect(to: Routes.password_reset_path(conn, :index))
  end

  def reset(conn, %{"token" => token}) do
    case PasswordResets.get(token) do
      {:error, _} ->
        conn
        |> put_flash(:error, "Password reset token not recognized.")
        |> redirect(to: Routes.login_path(conn, :index))

      _ ->
        render(conn, "reset.html", conn: conn, token: token)
    end
  end

  @spec finish_reset(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def finish_reset(conn, %{"token" => token, "password" => password}) do
    case PasswordResets.finish_reset(token, password) do
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Password reset token not recognized.")
        |> redirect(to: Routes.login_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Problem resetting password")
        |> redirect(to: Routes.login_path(conn, :index))

      {:ok, user} ->
        conn
        |> put_flash(:info, "Password for user #{user.username} reset successfully")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end
end
