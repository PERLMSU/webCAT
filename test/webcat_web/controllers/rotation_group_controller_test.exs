defmodule WebCATWeb.RotationGroupControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      rotation = Factory.insert(:rotation)
      Factory.insert_list(3, :rotation_group, rotation: rotation)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :index, rotation_id: rotation.id))
        |> json_response(:ok)

      assert Enum.count(result) == 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.rotation_group_path(conn, :index))
      |> json_response(:unauthorized)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      rotation_group = Factory.insert(:rotation_group)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :show, rotation_group.id))
        |> json_response(:ok)

      assert res["data"]["id"] == to_string(rotation_group.id)
      assert res["data"]["attributes"]["number"] == rotation_group.number
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:rotation_group)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.rotation_group_path(conn, :create), data)
        |> json_response(:created)

      assert res["data"]["attributes"]["number"] == data["number"]
    end

    test "doesn't allow normal users to create", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(
        Routes.rotation_group_path(conn, :create),
        Factory.string_params_for(:rotation_group)
      )
      |> json_response(:forbidden)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update =
        Factory.string_params_for(:rotation_group)
        |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(
          Routes.rotation_group_path(conn, :update, Factory.insert(:rotation_group).id),
          update
        )
        |> json_response(:ok)

      assert res["data"]["attributes"]["number"] == update["number"]
    end

    test "doesn't allow normal users to update", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:rotation_group)

      conn
      |> Auth.sign_in(user)
      |> put(
        Routes.rotation_group_path(conn, :update, Factory.insert(:rotation_group).id),
        update
      )
      |> json_response(:forbidden)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()
      data = Factory.insert(:rotation_group)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.rotation_group_path(conn, :delete, data.id))
      |> response(:no_content)

      conn
      |> Auth.sign_in(user)
      |> get(Routes.rotation_group_path(conn, :show, data.id))
      |> json_response(:not_found)
    end

    test "doesn't allow normal users to delete", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.rotation_group_path(conn, :delete, Factory.insert(:rotation_group).id))
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
