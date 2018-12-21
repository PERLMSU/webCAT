defmodule WebCATWeb.RotationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of rotations", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.rotation_path(conn, :index))
        |> html_response(200)

      assert response =~ "Rotations"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(DashboardRoutes.rotation_path(conn, :index))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays rotation", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)

        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.rotation_path(conn, :show, data.id))
        |> html_response(200)

    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation)

      redirect =
        conn
        |> get(DashboardRoutes.rotation_path(conn, :show, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a rotation", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.rotation_path(conn, :new))
        |> html_response(200)


      response =~ "Create New Rotation"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(DashboardRoutes.rotation_path(conn, :new))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates rotation", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:rotation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(DashboardRoutes.rotation_path(conn, :create), %{rotation: data})
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.rotation_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.params_with_assocs(:rotation)

      redirect =
        conn
        |> post(DashboardRoutes.rotation_path(conn, :create), %{rotation: data})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a rotation", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(DashboardRoutes.rotation_path(conn, :edit, data.id))
        |> html_response(200)

      response =~ "Edit Rotation"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation)

      redirect =
        conn
        |> get(DashboardRoutes.rotation_path(conn, :edit, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates data", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)
      update = Factory.params_with_assocs(:rotation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(DashboardRoutes.rotation_path(conn, :update, data.id), %{rotation: update})
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.rotation_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation)
      update = Factory.params_with_assocs(:rotation)

      redirect =
        conn
        |> put(DashboardRoutes.rotation_path(conn, :update, data.id), %{rotation: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes data", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> delete(DashboardRoutes.rotation_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ DashboardRoutes.rotation_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation)

      redirect =
        conn
        |> delete(DashboardRoutes.rotation_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
