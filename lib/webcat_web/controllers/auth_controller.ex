defmodule WebCATWeb.AuthController do
  use WebCATWeb, :controller

  alias WebCAT.Accounts.PasswordResets
  alias WebCAT.Accounts.Users

  action_fallback(WebCATWeb.FallbackController)

  def csrf(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{token: get_csrf_token()})
  end

  def login(conn, params) do
    with {:params, %{"email" => email, "password" => password}} <- {:params, params},
         {:login, {:ok, user}} <- {:login, Users.login(email, password)} do
      conn
      |> put_status(201)
      |> Auth.sign_in(user)
      |> put_status(201)
      |> text("OK")

    else
      {:params, _} ->
        {:error, "Authentication details not correctly supplied"}

      {:login, {:error, _}} ->
        {:error, "Incorrect email or password"}

      {:token, _} ->
        {:error, "Problem generating auth token"}
    end
  end

  def start_password_reset(conn, params) do
    with {:params, %{"email" => email}} <- {:params, params},
         {:email, {:ok, reset}} <- {:email, PasswordResets.start_reset(email)} do
      conn
      |> put_status(201)
      |> put_view(WebCATWeb.AuthView)
      |> render("token.json", token: reset.token)
    else
      {:params, _} ->
        {:error, "Reset details not correctly supplied"}

      {:email, _} ->
        {:error, "Email not found"}
    end
  end

  def finish_password_reset(conn, params) do
    with {:params, %{"token" => token, "new_password" => new_password}} <- {:params, params},
         {:reset, {:ok, user}} <- {:reset, PasswordResets.finish_reset(token, new_password)} do
      conn
      |> put_status(200)
      |> put_view(WebCATWeb.UserView)
      |> render("user.json", user: user)
    else
      {:params, _} ->
        {:error, "Reset details not correctly supplied."}

      {:reset, _} ->
        {:error, "There was a problem with your token."}
    end
  end
end
