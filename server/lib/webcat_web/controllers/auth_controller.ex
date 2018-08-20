defmodule WebCATWeb.AuthController do
  @moduledoc """
  Handle authentication tasks
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users
  alias WebCATWeb.AuthView

  action_fallback(InTheDoor.Web.FallbackController)

  def signup(conn, params) do
    case params do
      %{
        "email" => _,
        "password" => _,
        "username" => _,
        "first_name" => _,
        "last_name" => _
      } ->
        # Ensure they can't pass an admin role on signup
        with {:ok, user} <- Users.signup(Map.drop(params, ["role"])),
             {:ok, token, _} <-
               WebCATWeb.Auth.Guardian.encode_and_sign(user, %{}, token_type: "access") do
          conn
          |> put_status(:created)
          |> render(AuthView, "token.json", token: token)
        end

      _ ->
        {:error, %{error: "Invalid signup request"}}
    end
  end

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
        {:error, %{error: "Invalid login request"}}
    end
  end
end
