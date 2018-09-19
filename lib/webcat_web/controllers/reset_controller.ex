defmodule WebCATWeb.ResetController do
  @moduledoc """
  Handles resetting user passwords
  """
  use WebCATWeb, :controller

  alias WebCAT.Accounts.PasswordResets

  action_fallback(WebCATWeb.FallbackController)

  def show(conn, %{"token" => token}) do
    with {:ok, _} <- PasswordResets.get(token) do
      send_resp(conn, :ok, "")
    end
  end

  def create(conn, %{"email" => email}) do
    PasswordResets.start_reset(email)
    send_resp(conn, :ok, "")
  end

  def update(conn, %{"token" => token, "password" => password}) do
    with {:ok, _} <- PasswordResets.finish_reset(token, password) do
      send_resp(conn, :ok, "")
    end
  end
end
