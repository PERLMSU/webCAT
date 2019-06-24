defmodule WebCATWeb.ClassroomControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      Factory.insert_list(3, :classroom)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.classroom_path(conn, :index))
        |> json_response(200)

      assert Enum.count(result) >= 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.classroom_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      classroom_id = Factory.insert(:classroom).id

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.classroom_path(conn, :show, classroom_id))
        |> json_response(200)

      assert res["id"] == classroom_id
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_for(:classroom)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.classroom_path(conn, :create), data)
        |> json_response(201)

      assert res["name"] == data["name"]
    end

    test "doesn't allow normal users to create other users", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.classroom_path(conn, :create), Factory.string_params_for(:classroom))
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update =
        Factory.string_params_for(:classroom)
        |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.classroom_path(conn, :update, Factory.insert(:classroom).id), update)
        |> json_response(200)

      assert res["name"] == update["name"]
    end

    test "doesn't allow normal users to update classrooms", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:classroom)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.classroom_path(conn, :update, Factory.insert(:classroom).id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.classroom_path(conn, :delete, Factory.insert(:classroom).id))
      |> text_response(204)
    end

    test "doesn't allow normal users to delete classrooms", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.classroom_path(conn, :delete, Factory.insert(:classroom).id))
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
