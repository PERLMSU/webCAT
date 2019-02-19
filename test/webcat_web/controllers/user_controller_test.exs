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

      assert response =~ "Classrooms"
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

      assert Regex.match?(~r/#{Routes.user_path(conn, :index)}\/\d+/, redirect)
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
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
