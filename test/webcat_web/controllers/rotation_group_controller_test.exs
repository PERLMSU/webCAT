defmodule WebCATWeb.RotationGroupControllerTest do
  use WebCATWeb.ConnCase

  alias WebCAT.Rotations.RotationGroup

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of rotation groups", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :index))
        |> html_response(200)

      assert response =~ "Rotation Groups"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.rotation_group_path(conn, :index))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays rotation group", %{conn: conn, user: user} do
      data = Factory.insert(:rotation_group)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :show, data.id))
        |> html_response(200)

      response =~ RotationGroup.title_for(data)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation_group)

      redirect =
        conn
        |> get(Routes.rotation_group_path(conn, :show, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a rotation group", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :new))
        |> html_response(200)


      response =~ "Create New Category"
    end

    test "redirects user when not logged in", %{conn: conn} do
      redirect =
        conn
        |> get(Routes.rotation_group_path(conn, :new))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates rotation group", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:rotation_group)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.rotation_group_path(conn, :create), %{rotation_group: data})
        |> redirected_to(302)

      assert redirect =~ Routes.rotation_group_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.params_with_assocs(:rotation_group)

      redirect =
        conn
        |> post(Routes.rotation_group_path(conn, :create), %{rotation_group: data})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a rotation group", %{conn: conn, user: user} do
      data = Factory.insert(:rotation_group)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :edit, data.id))
        |> html_response(200)

      response =~ "Edit Rotation Group"
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation_group)

      redirect =
        conn
        |> get(Routes.rotation_group_path(conn, :edit, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a rotation group", %{conn: conn, user: user} do
      data = Factory.insert(:rotation_group)
      update = Factory.params_with_assocs(:rotation_group)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.rotation_group_path(conn, :update, data.id), %{rotation_group: update})
        |> redirected_to(302)

      assert redirect =~ Routes.rotation_group_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation_group)
      update = Factory.params_with_assocs(:rotation_group)

      redirect =
        conn
        |> put(Routes.rotation_group_path(conn, :update, data.id), %{rotation_group: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a rotation group", %{conn: conn, user: user} do
      data = Factory.insert(:rotation_group)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> delete(Routes.rotation_group_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.rotation_group_path(conn, :index)
    end

    test "redirects user when not logged in", %{conn: conn} do
      data = Factory.insert(:rotation_group)

      redirect =
        conn
        |> delete(Routes.rotation_group_path(conn, :delete, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :login)
    end
  end

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
