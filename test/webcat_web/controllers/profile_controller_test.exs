defmodule WebCATWeb.ProfileControllerTest do
  use WebCATWeb.ConnCase

  describe "show/3" do
    setup ~w(login_user)a

    test "displays user profile", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.profile_path(conn, :show))
        |> html_response(200)

      assert response =~ user.email
      assert response =~ user.first_name
      assert response =~ user.last_name

      assert response =~ "Edit"
      assert response =~ "Change Password"

      assert response =~ "Classrooms"
      assert response =~ "Sections"
      assert response =~ "Rotation Groups"
    end
  end

  describe "edit/3" do
    setup ~w(login_user)a

    test "displays user profile edit form", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.profile_path(conn, :edit))
        |> html_response(200)

      assert response =~ "Email"
      assert response =~ "First Name"
      assert response =~ "Last Name"
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a user profile", %{conn: conn, user: user} do
      update = Factory.params_with_assocs(:user)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.profile_path(conn, :update), %{user: update})
        |> redirected_to(302)

      assert redirect =~ Routes.profile_path(conn, :show)
    end
  end

  describe "edit_password/3" do
    setup ~w(login_user)a

    test "displays user profile change password form", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.profile_path(conn, :edit_password))
        |> html_response(200)

      assert response =~ "Current Password"
      assert response =~ "New Password"
      assert response =~ "Confirm New Password"
    end
  end

  describe "update_password/2" do
    setup ~w(login_user)a

    test "updates a user's password", %{conn: conn, user: user} do
      update = %{
        "current_password" => "password",
        "new_password" => "password1",
        "confirm_new_password" => "password1"
      }

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.profile_path(conn, :update_password), %{password_credential: update})
        |> redirected_to(302)

      assert redirect =~ Routes.login_path(conn, :index)
    end
  end

  defp login_user(_) do
    credential = Factory.insert(:password_credential, user: Factory.insert(:admin))
    {:ok, user: credential.user}
  end
end
