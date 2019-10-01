defmodule WebCATWeb.GradeControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      draft = Factory.insert(:student_draft)
      Factory.insert_list(3, :grade, draft: draft)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.grade_path(conn, :index, draft_id: draft.id))
        |> json_response(:ok)

      assert Enum.count(result) == 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.grade_path(conn, :index))
      |> json_response(:unauthorized)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      grade = Factory.insert(:grade)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.grade_path(conn, :show, grade.id))
        |> json_response(:ok)

      assert res["data"]["id"] == to_string(grade.id)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:grade)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.grade_path(conn, :create), data)
        |> json_response(:created)

      assert res["data"]["attributes"]["score"] == data["score"]
    end

    test "doesn't allow normal users to create grades", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.string_params_with_assocs(:grade)

      conn
      |> Auth.sign_in(user)
      |> post(Routes.grade_path(conn, :create), data)
      |> json_response(:forbidden)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:grade)
      update = Factory.string_params_with_assocs(:grade)

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.grade_path(conn, :update, data.id), update)
        |> json_response(:ok)

      assert res["data"]["attributes"]["score"] == update["score"]
    end

    test "doesn't allow normal users to update grades", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert(:grade)
      update = Factory.string_params_for(:grade)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.grade_path(conn, :update, data.id), update)
      |> json_response(:forbidden)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:grade)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.grade_path(conn, :delete, data.id))
      |> response(:no_content)

      conn
      |> Auth.sign_in(user)
      |> get(Routes.grade_path(conn, :show, data.id))
      |> json_response(:not_found)
    end

    test "doesn't allow normal users to delete grades", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert(:grade)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.grade_path(conn, :delete, data.id))
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
