defmodule WebCATWeb.AuthController do
  @moduledoc """
  Handle authentication tasks
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users
  alias WebCATWeb.AuthView

  action_fallback(WebCATWeb.FallbackController)



  def login(conn, params) do
    case params do
      %{"email" => email, "password" => password} ->
        with {:ok, user} <- Users.login(email, password),
             {:ok, token, _} <-
               WebCATWeb.Auth.Guardian.encode_and_sign(user, %{}, token_type: "access") do
          conn
          |> put_status(:created)
          |> render(AuthView, "token.json", token: token)
        end

      _ ->
        {:error, "Invalid login request"}
    end
  end
end
