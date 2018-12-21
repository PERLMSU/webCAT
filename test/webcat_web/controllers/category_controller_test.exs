defmodule WebCATWeb.CategoryControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of categories", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.category_path(conn, :index))
        |> html_response(200)

      assert response =~ "Categories"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(DashboardRoutes.category_path(conn, :index))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays category", %{conn: conn, user: user} do
      data = Factory.insert(:category)

        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.category_path(conn, :show, data.id))
        |> html_response(200)

    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:category)

      redirect =
        conn
        |> get(DashboardRoutes.category_path(conn, :show, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a category", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.category_path(conn, :new))
        |> html_response(200)


      response =~ "Create New Category"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(DashboardRoutes.category_path(conn, :new))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates category", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:category)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(DashboardRoutes.category_path(conn, :create), %{category: data})
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.category_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.params_with_assocs(:category)

      redirect =
        conn
        |> post(DashboardRoutes.category_path(conn, :create), %{category: data})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a category", %{conn: conn, user: user} do
      data = Factory.insert(:category)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.category_path(conn, :edit, data.id))
        |> html_response(200)

      response =~ "Edit Category"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:category)

      redirect =
        conn
        |> get(DashboardRoutes.category_path(conn, :edit, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates data", %{conn: conn, user: user} do
      data = Factory.insert(:category)
      update = Factory.params_with_assocs(:category)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(DashboardRoutes.category_path(conn, :update, data.id), %{category: update})
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.category_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:category)
      update = Factory.params_with_assocs(:category)

      redirect =
        conn
        |> put(DashboardRoutes.category_path(conn, :update, data.id), %{category: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes data", %{conn: conn, user: user} do
      data = Factory.insert(:category)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> delete(DashboardRoutes.category_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.category_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:category)

      redirect =
        conn
        |> delete(DashboardRoutes.category_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
