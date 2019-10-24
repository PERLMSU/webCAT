defmodule WebCATWeb.UserControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :index))
        |> json_response(:ok)

      assert Enum.count(result["data"]) == 1
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.user_path(conn, :index))
      |> json_response(:unauthorized)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :show, user.id))
        |> json_response(:ok)

      data = res["data"]
      attributes = data["attributes"]

      assert data["id"] == to_string(user.id)
      assert attributes["email"] == user.email
      assert attributes["first_name"] == user.first_name
      assert attributes["last_name"] == user.last_name
      assert attributes["middle_name"] == user.middle_name
      assert attributes["active"] == user.active
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_for(:user)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.user_path(conn, :create), data)
        |> json_response(:created)

      assert res["data"]["attributes"]["email"] == data["email"]
    end

    test "doesn't allow normal users to create other users", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.user_path(conn, :create), Factory.string_params_for(:user))
      |> json_response(:forbidden)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update = Factory.string_params_for(:user)

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.user_path(conn, :update, Factory.insert(:user).id), update)
        |> json_response(:ok)

      assert res["data"]["attributes"]["email"] == update["email"]
    end

    test "doesn't allow normal users to update other users", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:user)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.user_path(conn, :update, Factory.insert(:user).id), update)
      |> json_response(:forbidden)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:user)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.user_path(conn, :delete, data.id))
      |> response(:no_content)

      conn
      |> Auth.sign_in(user)
      |> get(Routes.user_path(conn, :show, data.id))
      |> json_response(:not_found)
    end

    test "doesn't allow normal users to delete other users", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.user_path(conn, :delete, Factory.insert(:user).id))
      |> json_response(:forbidden)
    end
  end

  defp login_admin() do
    user = Factory.insert(:admin)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end

  defp login_user() do
    user = Factory.insert(:user)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end
end
