defmodule WebCATWeb.ClassroomControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of classrooms", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.classroom_path(conn, :index))
        |> html_response(200)

      assert response =~ "Classrooms"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.classroom_path(conn, :index))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays classroom", %{conn: conn, user: user} do
      data = Factory.insert(:classroom)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.classroom_path(conn, :show, data.id))
        |> html_response(200)

      assert response =~ data.course_code
      assert response =~ data.title
      assert response =~ data.description

      assert response =~ "Semesters"
      assert response =~ "Users"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:classroom)

      redirect =
        conn
        |> get(Routes.classroom_path(conn, :show, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a classroom", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.classroom_path(conn, :new))
        |> html_response(200)

      assert response =~ "New Classroom"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.classroom_path(conn, :new))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates classroom", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:classroom)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.classroom_path(conn, :create), %{classroom: data})
        |> redirected_to(302)

      assert redirect =~ Routes.classroom_path(conn, :index) <> "\/\d+"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.params_with_assocs(:classroom)

      redirect =
        conn
        |> post(Routes.classroom_path(conn, :create), %{user: data})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a classroom", %{conn: conn, user: user} do
      data = Factory.insert(:classroom)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.classroom_path(conn, :edit, data.id))
        |> html_response(200)

      assert response =~ "Edit Classroom"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:classroom)

      redirect =
        conn
        |> get(Routes.classroom_path(conn, :edit, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a classroom", %{conn: conn, user: user} do
      data = Factory.insert(:classroom)
      update = Factory.params_with_assocs(:classroom)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.classroom_path(conn, :update, data.id), %{classroom: update})
        |> redirected_to(302)

      assert redirect =~ Routes.classroom_path(conn, :show, data.id)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:classroom)
      update = Factory.params_with_assocs(:classroom)

      redirect =
        conn
        |> put(Routes.classroom_path(conn, :update, data.id), %{classroom: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a classroom", %{conn: conn, user: user} do
      data = Factory.insert(:classroom)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.classroom_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.classroom_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:classroom)

      redirect =
        conn
        |> get(Routes.classroom_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
