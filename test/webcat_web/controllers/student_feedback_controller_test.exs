defmodule WebCATWeb.StudentFeedbackControllerTest do
  use WebCATWeb.ConnCase

  describe "classrooms/2" do
    setup ~w(login_user)a

    test "responds with list of classrooms the user is on", %{conn: conn, user: user} do
      semester = Factory.insert(:semester)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_feedback_path(conn, :classrooms))
        |> html_response(200)

      assert response =~ "Classroom: " <> semester.classroom.name
      assert response =~ semester.name
    end
  end

  describe "sections/2" do
    setup ~w(login_user)a

    test "responds with list of sections the user is on", %{conn: conn, user: user} do
      rotation = Factory.insert(:rotation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_feedback_path(conn, :sections, rotation.section.semester_id))
        |> html_response(200)

        assert response =~ "Section: #{rotation.section.number}"
        assert response =~ "Rotation #{rotation.number}"
    end
  end

  describe "groups/2" do
    setup ~w(login_user)a

    test "responds with list of rotation groups the user is on", %{conn: conn, user: user} do
      rotation_group = Factory.insert(:rotation_group)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_feedback_path(conn, :groups, rotation_group.rotation_id))
        |> html_response(200)

        assert response =~ "Group #{rotation_group.number}"
    end
  end

  describe "students/2" do
    setup ~w(login_user)a

    test "displays all necessary information about a rotation group", %{conn: conn, user: user} do
      rotation_group = Factory.insert(:rotation_group)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_feedback_path(conn, :students, rotation_group.id))
        |> html_response(200)

        assert response =~ "Rotation Group #{rotation_group.number}"

        Enum.each(rotation_group.users, fn user ->
          assert response =~ user.first_name <> " " <> user.last_name
          assert response =~ user.email
        end)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
