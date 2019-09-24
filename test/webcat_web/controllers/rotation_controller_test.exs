defmodule WebCATWeb.RotationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      section = Factory.insert(:section)
      Factory.insert_list(3, :rotation, section: section)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_path(conn, :index))
        |> json_response(200)

      assert Enum.count(result) >= 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.rotation_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      id = Factory.insert(:rotation).id

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_path(conn, :show, id))
        |> json_response(200)

      assert res["id"] == id
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:rotation)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.rotation_path(conn, :create), data)
        |> json_response(201)

      assert res["name"] == data["name"]
    end

    test "doesn't allow normal users to create", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.rotation_path(conn, :create), Factory.string_params_for(:rotation))
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update =
        Factory.string_params_for(:rotation)
        |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.rotation_path(conn, :update, Factory.insert(:rotation).id), update)
        |> json_response(200)

      assert res["name"] == update["name"]
    end

    test "doesn't allow normal users to update", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:rotation)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.rotation_path(conn, :update, Factory.insert(:rotation).id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:rotation)

      res =
        conn
        |> Auth.sign_in(user)
        |> delete(Routes.rotation_path(conn, :delete, data.id))
        |> json_response(200)

      assert res["data"]["attributes"]["number"] == data.number

      conn
      |> Auth.sign_in(user)
      |> get(Routes.rotation_path(conn, :show, data.id))
      |> json_response(404)
    end

    test "doesn't allow normal users to delete", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.rotation_path(conn, :delete, Factory.insert(:rotation).id))
      |> json_response(403)
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
