defmodule WebCATWeb.StudentFeedbackControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert_list(3, :student_feedback) |> Enum.at(0)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_feedback_path(conn, :index, data.rotation_group_id, data.user_id))
        |> json_response(200)

      assert Enum.count(result) >= 1
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.student_feedback_path(conn, :index, 1, 2))
      |> json_response(401)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.params_with_assocs(:student_feedback)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(
          Routes.student_feedback_path(
            conn,
            :create,
            data.rotation_group_id,
            data.user_id,
            data.feedback_id
          )
        )
        |> json_response(201)

      assert res["feedback_id"] == data.feedback_id
    end

    test "doesn't allow normal users to create student_feedback", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.student_feedback_path(conn, :create, 1, 2, 3))
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.params_with_assocs(:student_feedback)

      conn
      |> Auth.sign_in(user)
      |> delete(
        Routes.student_feedback_path(
          conn,
          :delete,
          data.rotation_group_id,
          data.user_id,
          data.feedback_id
        )
      )
      |> text_response(204)
    end

    test "doesn't allow normal users to delete student_feedback", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.student_feedback_path(conn, :delete, 1, 2, 3))
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