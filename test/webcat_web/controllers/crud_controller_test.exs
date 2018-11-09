defmodule WebCATWeb.CRUDControllerTest do
  use WebCATWeb.ConnCase

  @collections ~w(categories classrooms rotation_groups rotations semesters students users)
  @resource_names ~w(category classroom rotation_group rotation semester student user)a
  assert Enum.count(@collections) == Enum.count(@resource_names)
  @resources Enum.zip(@collections, @resource_names)

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of data", %{conn: conn, user: user} do
      for collection <- @collections do
        response =
          conn
          |> Auth.sign_in(user)
          |> get(Routes.crud_path(conn, :index, collection))
          |> html_response(200)

        assert response =~
                 collection
                 |> String.split("_")
                 |> Enum.map(&String.capitalize/1)
                 |> Enum.join(" ")
      end
    end

    test "redirects user when not logged in", %{conn: conn} do
      for collection <- @collections do
        redirect =
          conn
          |> get(Routes.crud_path(conn, :index, collection))
          |> redirected_to(302)

        assert redirect == Routes.login_path(conn, :login)
      end
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays data", %{conn: conn, user: user} do
      for {collection, resource_name} <- @resources do
        conn
        |> Auth.sign_in(user)
        |> get(Routes.crud_path(conn, :show, collection, Factory.insert(resource_name).id))
        |> html_response(200)
      end
    end

    test "redirects user when not logged in", %{conn: conn} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> get(Routes.crud_path(conn, :show, collection, Factory.insert(resource_name).id))
          |> redirected_to(302)

        assert redirect == Routes.login_path(conn, :login)
      end
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create data", %{conn: conn, user: user} do
      for collection <- @collections do
        conn
        |> Auth.sign_in(user)
        |> get(Routes.crud_path(conn, :new, collection))
        |> html_response(200)
      end
    end

    test "redirects user when not logged in", %{conn: conn} do
      for collection <- @collections do
        redirect =
          conn
          |> get(Routes.crud_path(conn, :new, collection))
          |> redirected_to(302)

        assert redirect == Routes.login_path(conn, :login)
      end
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates data", %{conn: conn, user: user} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> Auth.sign_in(user)
          |> post(
            Routes.crud_path(conn, :create, collection),
            Map.put(%{}, resource_name, Factory.params_with_assocs(resource_name))
          )
          |> redirected_to(302)

        assert redirect =~ Routes.crud_path(conn, :index, collection)
      end
    end

    test "redirects user when not logged in", %{conn: conn} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> post(
            Routes.crud_path(conn, :create, collection),
            Map.put(%{}, resource_name, Factory.params_with_assocs(resource_name))
          )
          |> redirected_to(302)

        assert redirect == Routes.login_path(conn, :login)
      end
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update data", %{conn: conn, user: user} do
      for {collection, resource_name} <- @resources do
        conn
        |> Auth.sign_in(user)
        |> get(Routes.crud_path(conn, :edit, collection, Factory.insert(resource_name).id))
        |> html_response(200)
      end
    end

    test "redirects user when not logged in", %{conn: conn} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> get(Routes.crud_path(conn, :edit, collection, Factory.insert(resource_name).id))
          |> redirected_to(302)

        assert redirect == Routes.login_path(conn, :login)
      end
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates data", %{conn: conn, user: user} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> Auth.sign_in(user)
          |> put(
            Routes.crud_path(conn, :update, collection, Factory.insert(resource_name).id),
            Map.put(%{}, resource_name, Factory.params_with_assocs(resource_name))
          )
          |> redirected_to(302)

        assert redirect =~ Routes.crud_path(conn, :index, collection)
      end
    end

    test "redirects user when not logged in", %{conn: conn} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> put(
            Routes.crud_path(conn, :update, collection, Factory.insert(resource_name).id),
            Map.put(%{}, resource_name, Factory.params_with_assocs(resource_name))
          )
          |> redirected_to(302)

        assert redirect == Routes.login_path(conn, :login)
      end
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes data", %{conn: conn, user: user} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> Auth.sign_in(user)
          |> delete(Routes.crud_path(conn, :delete, collection, Factory.insert(resource_name).id))
          |> redirected_to(302)

        assert redirect =~ Routes.crud_path(conn, :index, collection)
      end
    end

    test "redirects user when not logged in", %{conn: conn} do
      for {collection, resource_name} <- @resources do
        redirect =
          conn
          |> delete(Routes.crud_path(conn, :delete, collection, Factory.insert(resource_name).id))
          |> redirected_to(302)

        assert redirect == Routes.login_path(conn, :login)
      end
    end
  end

  defp login_user(_) do
    {:ok, user} = Users.login("wcat_admin@msu.edu", "password")
    {:ok, user: user}
  end
end
