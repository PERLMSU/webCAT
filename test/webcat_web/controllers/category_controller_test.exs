defmodule WebCATWeb.CategoryControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      Factory.insert_list(3, :category)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.category_path(conn, :index))
        |> json_response(200)

      assert Enum.count(result) >= 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.category_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      category = Factory.insert(:category)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.category_path(conn, :show, category.id))
        |> json_response(200)

      data = res["data"]
      attributes = data["attributes"]

      assert data["id"] == to_string(category.id)
      assert attributes["name"] == category.name
      assert attributes["description"] == category.description
      assert attributes["parent_category_id"] == category.parent_category_id
      assert attributes["classroom_id"] == category.classroom_id
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      category = Factory.string_params_for(:category)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.category_path(conn, :create), category)
        |> json_response(201)

      assert res["data"]["attributes"]["name"] == category["name"]
    end

    test "doesn't allow normal users to create categories", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.category_path(conn, :create), Factory.string_params_for(:category))
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update =
        Factory.string_params_for(:category)
        |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.category_path(conn, :update, Factory.insert(:category).id), update)
        |> json_response(200)

      assert res["data"]["attributes"]["name"] == update["name"]
    end

    test "doesn't allow normal users to update categories", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:category)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.category_path(conn, :update, Factory.insert(:category).id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.category_path(conn, :delete, Factory.insert(:category).id))
      |> json_response(200)
    end

    test "doesn't allow normal users to delete categories", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.category_path(conn, :delete, Factory.insert(:category).id))
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
