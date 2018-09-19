defmodule WebCATWeb.ConfirmationController do
  @moduledoc """
  Handles confirming user accounts
  """
  use WebCATWeb, :controller

  alias WebCAT.Accounts.Confirmations

  action_fallback(WebCATWeb.FallbackController)

  def show(conn, %{"token" => token}) do
    with {:ok, _confirmation} <- Confirmations.get(token) do
      send_resp(conn, :ok, "")
    end
  end

  def update(conn, %{"token" => token}) do
    with {:ok, _confirmation} <- Confirmations.confirm(token) do
      send_resp(conn, :ok, "")
    end
  end
end
