defmodule WebCATWeb.SemesterControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of semesters", %{conn: conn, user: user} do
      classroom = Factory.insert(:classroom)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.semester_path(conn, :index, classroom.id))
        |> html_response(200)

      assert response =~ "Semesters"
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays semester", %{conn: conn, user: user} do
      data = Factory.insert(:semester)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.semester_path(conn, :show, data.classroom_id, data.id))
        |> html_response(200)

      assert response =~ data.name
      assert response =~ data.description
      assert response =~ Timex.format!(data.start_date, "{M}-{D}-{YYYY}")
      assert response =~ Timex.format!(data.end_date, "{M}-{D}-{YYYY}")

      assert response =~ "Semesters"
      assert response =~ "Users"
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a semester", %{conn: conn, user: user} do
      classroom = Factory.insert(:classroom)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.semester_path(conn, :new, classroom.id))
        |> html_response(200)

      assert response =~ "New Semester"
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates semester", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:semester)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.semester_path(conn, :create, data.classroom_id), %{semester: data})
        |> redirected_to(302)

      assert Regex.match?(
               ~r/#{Routes.semester_path(conn, :index, data.classroom_id)}\/\d+/,
               redirect
             )
    end

    test "displays form errors if create fails", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:semester) |> Map.drop(~w(name)a)

      response =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.semester_path(conn, :create, data.classroom_id), %{semester: data})
        |> html_response(200)

      assert response =~ "New Semester"
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a semester", %{conn: conn, user: user} do
      data = Factory.insert(:semester)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.semester_path(conn, :edit, data.classroom_id, data.id))
        |> html_response(200)

      assert response =~ "Edit Semester"
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a semester", %{conn: conn, user: user} do
      data = Factory.insert(:semester)
      update = Factory.params_with_assocs(:semester)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.semester_path(conn, :update, data.classroom_id, data.id), %{
          semester: update
        })
        |> redirected_to(302)

      assert redirect =~ Routes.semester_path(conn, :show, data.classroom_id, data.id)
    end

    test "displays form errors if update fails", %{conn: conn, user: user} do
      data = Factory.insert(:semester)
      update = Factory.params_with_assocs(:semester) |> Map.put(:name, nil)

      response =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.semester_path(conn, :update, data.classroom_id, data.id), %{
          semester: update
        })
        |> html_response(200)

      assert response =~ "Edit Semester"
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a semester", %{conn: conn, user: user} do
      data = Factory.insert(:semester)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.semester_path(conn, :delete, data.classroom_id, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.semester_path(conn, :index, data.classroom_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
