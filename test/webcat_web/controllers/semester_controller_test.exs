defmodule WebCATWeb.SemesterControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of semesters", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.semester_path(conn, :index))
        |> html_response(200)

      assert response =~ "Semesters"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(DashboardRoutes.semester_path(conn, :index))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays semester", %{conn: conn, user: user} do
      data = Factory.insert(:semester)

        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.semester_path(conn, :show, data.id))
        |> html_response(200)

    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:semester)

      redirect =
        conn
        |> get(DashboardRoutes.semester_path(conn, :show, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a semester", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.semester_path(conn, :new))
        |> html_response(200)


      response =~ "Create New Semester"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(DashboardRoutes.semester_path(conn, :new))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates semester", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:semester)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(DashboardRoutes.semester_path(conn, :create), %{semester: data})
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.semester_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.params_with_assocs(:semester)

      redirect =
        conn
        |> post(DashboardRoutes.semester_path(conn, :create), %{semester: data})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a semester", %{conn: conn, user: user} do
      data = Factory.insert(:semester)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.semester_path(conn, :edit, data.id))
        |> html_response(200)

      response =~ "Edit Semester"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:semester)

      redirect =
        conn
        |> get(DashboardRoutes.semester_path(conn, :edit, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
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
        |> put(DashboardRoutes.semester_path(conn, :update, data.id), %{semester: update})
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.semester_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:semester)
      update = Factory.params_with_assocs(:semester)

      redirect =
        conn
        |> put(DashboardRoutes.semester_path(conn, :update, data.id), %{semester: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a semester", %{conn: conn, user: user} do
      data = Factory.insert(:semester)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> delete(DashboardRoutes.semester_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.semester_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:semester)

      redirect =
        conn
        |> delete(DashboardRoutes.semester_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
