defmodule WebCATWeb.StudentExplanationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      explanation = Factory.insert(:explanation)
      Factory.insert_list(3, :student_explanation, explanation: explanation)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_explanation_path(conn, :index, explanation_id: explanation.id))
        |> json_response(200)

      assert Enum.count(result) == 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.student_explanation_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.params_with_assocs(:student_explanation)

      res =
        conn
        |> Auth.sign_in(user)
        |> post( Routes.student_explanation_path(conn, :create, data))
        |> json_response(201)

      attributes = res["data"]["attributes"]

      assert attributes["feedback_id"] == data.feedback_id
      assert attributes["explanation_id"] == data.explanation_id
      assert attributes["draft_id"] == data.draft_id
    end

    test "doesn't allow normal users to create student_explanation", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.params_with_assocs(:student_explanation)

      conn
      |> Auth.sign_in(user)
      |> post(Routes.student_explanation_path(conn, :create, data))
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:student_explanation)

      conn
      |> Auth.sign_in(user)
      |> delete(
        Routes.student_explanation_path(conn, :delete, data.id))
      |> json_response(200)
    end

    test "doesn't allow normal users to delete student_explanation", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert(:student_explanation)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.student_explanation_path(conn, :delete, data.id))
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
