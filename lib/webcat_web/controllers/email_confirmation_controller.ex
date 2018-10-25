defmodule WebCATWeb.EmailConfirmationController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Confirmations

  action_fallback(WebCATWeb.FallbackController)

  def confirm(conn, %{"token" => token}) do
    case Confirmations.confirm(token) do
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Email confirmation token is not valid!")
        |> redirect(to: Routes.login_path(conn, :index))

      {:error, :bad_request} ->
        conn
        |> put_flash(:info, "Email already confirmed!")
        |> redirect(to: Routes.login_path(conn, :index))

      _ ->
        conn
        |> put_flash(:info, "Email successfully confirmed!")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end
end
