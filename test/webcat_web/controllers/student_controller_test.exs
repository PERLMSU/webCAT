defmodule WebCATWeb.StudentControllerTest do
  use WebCATWeb.ConnCase

  alias WebCAT.Rotations.Student

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of students", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_path(conn, :index))
        |> html_response(200)

      assert response =~ "Students"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.student_path(conn, :index))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays student", %{conn: conn, user: user} do
      data = Factory.insert(:student)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_path(conn, :show, data.id))
        |> html_response(200)

      response =~ Student.title_for(data)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:student)

      redirect =
        conn
        |> get(Routes.student_path(conn, :show, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a student", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_path(conn, :new))
        |> html_response(200)


      response =~ "Create New Category"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.student_path(conn, :new))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates student", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:student)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.student_path(conn, :create), %{student: data})
        |> redirected_to(302)

      assert redirect =~ Routes.student_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.params_with_assocs(:student)

      redirect =
        conn
        |> post(Routes.student_path(conn, :create), %{student: data})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a student", %{conn: conn, user: user} do
      data = Factory.insert(:student)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.student_path(conn, :edit, data.id))
        |> html_response(200)

      response =~ "Edit Rotation Group"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:student)

      redirect =
        conn
        |> get(Routes.student_path(conn, :edit, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a student", %{conn: conn, user: user} do
      data = Factory.insert(:student)
      update = Factory.params_with_assocs(:student)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.student_path(conn, :update, data.id), %{student: update})
        |> redirected_to(302)

      assert redirect =~ Routes.student_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:student)
      update = Factory.params_with_assocs(:student)

      redirect =
        conn
        |> put(Routes.student_path(conn, :update, data.id), %{student: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a student", %{conn: conn, user: user} do
      data = Factory.insert(:student)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> delete(Routes.student_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.student_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:student)

      redirect =
        conn
        |> delete(Routes.student_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
