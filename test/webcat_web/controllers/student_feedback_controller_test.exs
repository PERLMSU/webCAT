defmodule WebCATWeb.StudentFeedbackControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()
      feedback = Factory.insert(:feedback)
      Factory.insert_list(3, :student_feedback, feedback: feedback)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_feedback_path(conn, :index, filter: %{feedback_id: feedback.id}))
        |> json_response(:ok)

      assert Enum.count(res["data"]) == 3
    end


    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.student_feedback_path(conn, :index))
      |> json_response(:unauthorized)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.params_with_assocs(:student_feedback)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.student_feedback_path(conn, :create, data))
        |> json_response(:created)

      attributes = res["data"]["attributes"]

      assert attributes["feedback_id"] == data.feedback_id
      assert attributes["draft_id"] == data.draft_id
    end

    test "doesn't allow normal users to create student_feedback", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.params_with_assocs(:student_feedback)

      conn
      |> Auth.sign_in(user)
      |> post(Routes.student_feedback_path(conn, :create, data))
      |> json_response(:forbidden)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:student_feedback)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.student_feedback_path(conn, :delete, data.id))
      |> response(:no_content)

      conn
      |> Auth.sign_in(user)
      |> get(Routes.student_feedback_path(conn, :delete, data.id))
      |> json_response(:not_found)
    end

    test "doesn't allow normal users to delete student_feedback", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert(:student_feedback)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.student_feedback_path(conn, :delete, data.id))
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
