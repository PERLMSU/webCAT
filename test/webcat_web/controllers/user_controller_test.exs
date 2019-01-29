defmodule WebCATWeb.UserControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of users", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :index))
        |> html_response(200)

      assert response =~ "Users"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.user_path(conn, :index))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays user", %{conn: conn, user: user} do
      data = Factory.insert(:user)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :show, data.id))
        |> html_response(200)

      assert response =~ data.first_name
      assert response =~ data.last_name
      assert response =~ data.email
      assert response =~ data.role
      assert response =~ data.bio

      assert response =~ "Classrooms"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:user)

      redirect =
        conn
        |> get(Routes.user_path(conn, :show, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a user", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :new))
        |> html_response(200)

      assert response =~ "New User"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.user_path(conn, :new))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates user", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:user)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.user_path(conn, :create), %{user: data})
        |> redirected_to(302)

      assert redirect =~ Routes.user_path(conn, :index) <> "\/\d+"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.params_with_assocs(:user)

      redirect =
        conn
        |> post(Routes.user_path(conn, :create), %{user: data})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a user", %{conn: conn, user: user} do
      data = Factory.insert(:user)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :edit, data.id))
        |> html_response(200)

      assert response =~ "Edit User"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:user)

      redirect =
        conn
        |> get(Routes.user_path(conn, :edit, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a user", %{conn: conn, user: user} do
      data = Factory.insert(:user)
      update = Factory.params_with_assocs(:user)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.user_path(conn, :update, data.id), %{user: update})
        |> redirected_to(302)

      assert redirect =~ Routes.user_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:user)
      update = Factory.params_with_assocs(:user)

      redirect =
        conn
        |> put(Routes.user_path(conn, :update, data.id), %{user: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a user", %{conn: conn, user: user} do
      data = Factory.insert(:user)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.user_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:user)

      redirect =
        conn
        |> get(Routes.user_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "import/2" do
    setup ~w(login_user)a

    test "shows user import dialog", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.user_path(conn, :import))
        |> html_response(200)

      assert response =~ "Import Users"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.classroom_path(conn, :import))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
