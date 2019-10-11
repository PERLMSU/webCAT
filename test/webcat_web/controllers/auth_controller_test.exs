defmodule WebCATWeb.AuthControllerTest do
  use WebCATWeb.ConnCase

  describe "login/2" do
    test "responds normally to a well formed email/password login request", %{conn: conn} do
      {:ok, user} = login_user()

      result =
        conn
        |> post(Routes.auth_path(conn, :login), %{email: user.email, password: "password"})
        |> json_response(:created)

      assert String.length(result["token"]) > 0
      assert result["user"]["data"]["attributes"]["email"] == user.email
    end

    test "responds normally to a well formed token login request", %{conn: conn} do
      {:ok, user} = login_user()

      token = Factory.insert(:token_credential, user: user)

      result =
        conn
        |> post(Routes.auth_path(conn, :login, token: token.token))
        |> json_response(:created)

      assert String.length(result["token"]) > 0
      assert result["user"]["data"]["attributes"]["email"] == user.email

      conn
      |> post(Routes.auth_path(conn, :login, token: token.token))
      |> json_response(:not_found)
    end

    test "errors correctly when wrong parameters supplied", %{conn: conn} do
      conn
      |> post(Routes.auth_path(conn, :login), %{username: "username"})
      |> json_response(:bad_request)

      conn
      |> post(Routes.auth_path(conn, :login), %{email: "aaa@bbb.ccc", name: "yeet"})
      |> json_response(:bad_request)

      conn
      |> post(Routes.auth_path(conn, :login), %{password: "gong", name: "yeet"})
      |> json_response(:bad_request)
    end

    test "errors when incorrect email or password", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> post(Routes.auth_path(conn, :login), %{email: user.email, password: "not_password"})
      |> json_response(:not_found)

      conn
      |> post(Routes.auth_path(conn, :login), %{email: "not.email@aaa.bbb", password: "password"})
      |> json_response(:not_found)

      conn
      |> post(Routes.auth_path(conn, :login), %{
        email: "not.email@aaa.bbb",
        password: "not_password"
      })
      |> json_response(:not_found)
    end
  end

  describe "start_password_reset/2" do
    test "responds normally with an existing email", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> post(Routes.auth_path(conn, :start_password_reset), %{email: user.email})
      |> response(:no_content)
    end

    test "fails with a faulty email", %{conn: conn} do
      conn
      |> post(Routes.auth_path(conn, :start_password_reset), %{email: "does.not.exist@yeet.meat"})
      |> json_response(:not_found)
    end
  end

  describe "finish_password_reset/2" do
    test "responds normally with a good token", %{conn: conn} do
      {:ok, user} = login_user()
      reset = Factory.insert(:password_reset, user: user)

      conn
      |> post(Routes.auth_path(conn, :finish_password_reset), %{
        token: reset.token,
        new_password: "new_password"
      })
      |> json_response(:ok)

      # Cannot do it twice
      conn
      |> post(Routes.auth_path(conn, :finish_password_reset), %{
        token: reset.token,
        new_password: "new_password_2"
      })
      |> json_response(:not_found)
    end

    test "fails with faulty params", %{conn: conn} do
      {:ok, user} = login_user()

      reset = Factory.insert(:password_reset, user: user)

      conn
      |> post(Routes.auth_path(conn, :finish_password_reset), %{token: reset.token})
      |> json_response(:bad_request)

      conn
      |> post(Routes.auth_path(conn, :finish_password_reset), %{
        yeet: "meat",
        new_password: "new_password"
      })
      |> json_response(:bad_request)
    end

    test "fails with a faulty token", %{conn: conn} do
      conn
      |> post(Routes.auth_path(conn, :finish_password_reset), %{
        token: "aaaaaaa",
        new_password: "new_password"
      })
      |> json_response(:not_found)
    end
  end

  defp login_user() do
    user = Factory.insert(:admin)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end
end
