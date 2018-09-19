defmodule WebCATWeb.UserControllerTest do
  @moduledoc false

  use WebCATWeb.ConnCase, async: true

  describe "index/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.insert(:user)

      conn
      |> put_token(user)
      |> get(Helpers.user_path(conn, :index))
      |> json_response(200)
    end
  end

  describe "show/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.insert(:user)

      response =
        conn
        |> put_token(user)
        |> get(Helpers.user_path(conn, :show, user.id))
        |> json_response(200)

      assert response["id"] == user.id
    end
  end

  describe "update/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.insert(:user)
      update = Factory.string_params_for(:user)

      response =
        conn
        |> put_token(user)
        |> patch(Helpers.user_path(conn, :update, user.id), update)
        |> json_response(200)

      assert response["id"] == user.id
      assert response["email"] == update["email"]
    end

    test "allows admins to update any user", %{conn: conn} do
      admin = Factory.insert(:user, role: "admin")
      user = Factory.insert(:user)
      update = Factory.string_params_for(:user)

      conn
      |> put_token(admin)
      |> patch(Helpers.user_path(conn, :update, user.id), update)
      |> json_response(200)
    end

    test "blocks normal users from updating other users", %{conn: conn} do
      not_admin = Factory.insert(:user)
      user = Factory.insert(:user)
      update = Factory.string_params_for(:user)

      conn
      |> put_token(not_admin)
      |> patch(Helpers.user_path(conn, :update, user.id), update)
      |> json_response(401)
    end
  end

  describe "notifications/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.insert(:user, notifications: Factory.insert_list(5, :notification))

      response =
        conn
        |> put_token(user)
        |> get(Helpers.user_path(conn, :notifications, user.id))
        |> json_response(200)

      assert Enum.count(response) == 5
    end
  end

  describe "classrooms/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.insert(:user, classrooms: Factory.insert_list(5, :classroom))

      response =
        conn
        |> put_token(user)
        |> get(Helpers.user_path(conn, :classrooms, user.id))
        |> json_response(200)

      assert Enum.count(response) == 5
    end
  end

  describe "rotation_groups/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.insert(:user, rotation_groups: Factory.insert_list(5, :rotation_group))

      response =
        conn
        |> put_token(user)
        |> get(Helpers.user_path(conn, :rotation_groups, user.id))
        |> json_response(200)

      assert Enum.count(response) == 5
    end
  end

  defp put_token(conn, user) do
    {:ok, token, _} = WebCATWeb.Auth.Guardian.encode_and_sign(user, %{}, token_type: "access")
    put_req_header(conn, "authorization", "bearer #{token}")
  end
end
