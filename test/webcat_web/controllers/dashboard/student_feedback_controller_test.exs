defmodule WebCATWeb.StudentFeedbackControllerTest do
  use WebCATWeb.ConnCase

  describe "classrooms/3" do
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

  describe "sections/3" do
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

  describe "groups/3" do
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

  describe "students/3" do
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

  describe "categories/3" do
    setup ~w(login_user)a

    test "shows feedback for a student", %{conn: conn, user: user} do
      student_feedback = Factory.insert(:student_feedback)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(
          Routes.student_feedback_path(
            conn,
            :categories,
            student_feedback.rotation_group_id,
            student_feedback.user_id
          )
        )
        |> html_response(200)

      assert response =~ student_feedback.feedback.content
      assert response =~ student_feedback.feedback.observation.content
      assert response =~ student_feedback.feedback.observation.category.name
    end

    test "works with sub-categories", %{conn: conn, user: user} do
      category = Enum.random(Factory.insert(:category).sub_categories)
      observation = Factory.insert(:observation, category: category)
      feedback = Factory.insert(:feedback, observation: observation)
      student_feedback = Factory.insert(:student_feedback, feedback: feedback)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(
          Routes.student_feedback_path(
            conn,
            :categories,
            student_feedback.rotation_group_id,
            student_feedback.user_id,
            category_id: category.parent_category_id
          )
        )
        |> html_response(200)

      assert response =~ feedback.content
      assert response =~ observation.content
      assert response =~ category.name
    end
  end

  describe "feedback/3" do
    setup ~w(login_user)a

    test "allows adding and removing feedback for a student", %{conn: conn, user: user} do
      other_feedback = Factory.insert(:feedback)
      student_feedback = Factory.insert(:student_feedback)

      body = %{
        "student_feedback" => %{
          to_string(other_feedback.id) => "true",
          to_string(student_feedback.feedback.id) => "false"
        }
      }

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(
          Routes.student_feedback_path(
            conn,
            :feedback,
            student_feedback.rotation_group_id,
            student_feedback.user_id
          ),
          body
        )
        |> redirected_to()

      assert redirect =~
               Routes.student_feedback_path(conn, :students, student_feedback.rotation_group_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
