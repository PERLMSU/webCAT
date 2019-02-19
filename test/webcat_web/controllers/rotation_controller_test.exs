defmodule WebCATWeb.RotationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of rotations", %{conn: conn, user: user} do
      section = Factory.insert(:section)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_path(conn, :index, section.id))
        |> html_response(200)

      assert response =~ "Rotations"
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays rotation", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_path(conn, :show, data.section_id, data.id))
        |> html_response(200)

      assert response =~ to_string(data.number)
      assert response =~ data.description

      assert response =~ "Rotation Groups"
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a rotation", %{conn: conn, user: user} do
      section = Factory.insert(:section)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_path(conn, :new, section.id))
        |> html_response(200)

      assert response =~ "New Rotation"
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates rotation", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:rotation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.rotation_path(conn, :create, data.section_id), %{rotation: data})
        |> redirected_to(302)

      assert Regex.match?(
               ~r/#{Routes.rotation_path(conn, :index, data.section_id)}\/\d+/,
               redirect
             )
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a rotation", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_path(conn, :edit, data.section_id, data.id))
        |> html_response(200)

      assert response =~ "Edit Rotation"
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a rotation", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)
      update = Factory.params_with_assocs(:rotation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.rotation_path(conn, :update, data.section_id, data.id), %{
          rotation: update
        })
        |> redirected_to(302)

      assert redirect =~ Routes.rotation_path(conn, :show, data.section_id, data.id)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a rotation", %{conn: conn, user: user} do
      data = Factory.insert(:rotation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_path(conn, :delete, data.section_id, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.rotation_path(conn, :index, data.section_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
