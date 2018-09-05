defmodule WebCATWeb.ConfirmationController do
  @moduledoc """
  Handles confirming user accounts
  """
  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users

  action_fallback(WebCATWeb.FallbackController)

end
