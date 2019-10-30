defmodule WebCATWeb.AuthController do
  use WebCATWeb, :controller

  alias WebCAT.Accounts.PasswordResets
  alias WebCAT.Accounts.Users
  alias WebCATWeb.UserView

  action_fallback(WebCATWeb.FallbackController)

  def login(conn, params) do
    case params do
      %{"email" => email, "password" => password} ->
        with {:login, {:ok, user}} <- {:login, Users.login(email, password)},
             {:token, {:ok, token, _}} <- {:token, WebCATWeb.Auth.Guardian.encode_and_sign(user)} do
          conn
          |> put_status(201)
          |> json(%{token: token, user: UserView.show(user, conn, %{})})
        else
          {:login, {:error, _}} ->
            {:error, :not_found, dgettext("errors", "Email or password incorrect")}

          {:token, _} ->
            {:error, :server_error, dgettext("errors", "Problem generating authentication token")}
        end

      %{"token" => token} ->
        with {:login, {:ok, user}} <- {:login, Users.login(token)},
             {:token, {:ok, token, _}} <- {:token, WebCATWeb.Auth.Guardian.encode_and_sign(user)} do
          conn
          |> put_status(201)
          |> json(%{token: token, user: UserView.show(user, conn, %{})})
        else
          {:login, {:error, _}} ->
            {:error, :not_found, dgettext("errors", "Login token not found or expired")}

          {:token, _} ->
            {:error, :server_error, dgettext("errors", "Problem generating authentication token")}
        end

      _ ->
        {:error, :bad_request, dgettext("errors", "Login details not supplied")}
    end
  end

  def start_password_reset(conn, params) do
    with {:params, %{"email" => email}} <- {:params, params},
         {:email, {:ok, _reset}} <- {:email, PasswordResets.start_reset(email)} do
      send_resp(conn, :no_content, "")
    else
      {:params, _} ->
        {:error, :bad_request, dgettext("errors", "Reset details not correctly supplied")}

      {:email, _} ->
        {:error, :not_found, dgettext("errors", "Email not found")}
    end
  end

  def finish_password_reset(conn, params) do
    with {:params, %{"token" => token, "new_password" => new_password}} <- {:params, params},
         {:reset, {:ok, user}} <- {:reset, PasswordResets.finish_reset(token, new_password)},
         {:token, {:ok, token, _}} <- {:token, WebCATWeb.Auth.Guardian.encode_and_sign(user)} do
      conn
      |> put_status(:ok)
      |> json(%{token: token, user: UserView.show(user, conn, %{})})
    else
      {:params, _} ->
        {:error, :bad_request, dgettext("errors", "Reset details not correctly supplied.")}

      {:reset, _} ->
        {:error, :not_found, dgettext("errors", "Reset token not found")}

      {:token, _} ->
        {:error, :server_error, dgettext("errors", "Problem generating authentication token")}
    end
  end
end
