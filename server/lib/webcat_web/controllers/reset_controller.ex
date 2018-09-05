defmodule WebCATWeb.ResetController do
  @moduledoc """
  Handles resetting user passwords
  """
  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users
  
  action_fallback(WebCATWeb.FallbackController)

  def show(conn, %{"token" => token}) do

  end

  def update(conn, %{"token" => token}) do

  end
end
