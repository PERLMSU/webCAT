defmodule WebCATWeb.StudentExplanationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert_list(3, :student_explanation) |> Enum.at(0)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(
          Routes.student_explanation_path(
            conn,
            :index,
            data.rotation_group_id,
            data.student_id
          )
        )
        |> json_response(200)

      assert Enum.count(result) >= 1
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.student_explanation_path(conn, :index, 1, 2))
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
        |> post(
          Routes.student_explanation_path(
            conn,
            :create,
            data.rotation_group_id,
            data.student_id,
            data.feedback_id,
            data.explanation_id
          )
        )
        |> json_response(201)

      assert res["feedback_id"] == data.feedback_id
    end

    test "doesn't allow normal users to create student_explanation", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.student_explanation_path(conn, :create, 1, 2, 3, 4))
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.params_with_assocs(:student_explanation)

      conn
      |> Auth.sign_in(user)
      |> delete(
        Routes.student_explanation_path(
          conn,
          :delete,
          data.rotation_group_id,
          data.student_id,
          data.feedback_id,
          data.explanation_id
        )
      )
      |> text_response(204)
    end

    test "doesn't allow normal users to delete student_explanation", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.student_explanation_path(conn, :delete, 1, 2, 3, 4))
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
