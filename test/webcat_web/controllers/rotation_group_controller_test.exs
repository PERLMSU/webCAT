defmodule WebCATWeb.RotationGroupControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of rotation groups", %{conn: conn, user: user} do
      rotation = Factory.insert(:rotation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :index, rotation.id))
        |> html_response(200)

      assert response =~ "Rotations"
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays rotation group", %{conn: conn, user: user} do
      data = Factory.insert(:rotation_group)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :show, data.rotation_id, data.id))
        |> html_response(200)

      assert response =~ to_string(data.number)
      assert response =~ data.description

      assert response =~ "Rotation Groups"
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a rotation group", %{conn: conn, user: user} do
      rotation = Factory.insert(:rotation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :new, rotation.id))
        |> html_response(200)

      assert response =~ "New Rotation"
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates rotation group", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:rotation_group)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.rotation_group_path(conn, :create, data.rotation_id), %{rotation_group: data})
        |> redirected_to(302)

      assert Regex.match?(
               ~r/#{Routes.rotation_group_path(conn, :index, data.rotation_id)}\/\d+/,
               redirect
             )
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a rotation group", %{conn: conn, user: user} do
      data = Factory.insert(:rotation_group)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :edit, data.rotation_id, data.id))
        |> html_response(200)

      assert response =~ "Edit Rotation"
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
        |> put(Routes.rotation_group_path(conn, :update, data.rotation_id, data.id), %{
          rotation_group: update
        })
        |> redirected_to(302)

      assert redirect =~ Routes.rotation_group_path(conn, :show, data.rotation_id, data.id)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a rotation group", %{conn: conn, user: user} do
      data = Factory.insert(:rotation_group)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.rotation_group_path(conn, :delete, data.rotation_id, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.rotation_group_path(conn, :index, data.rotation_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
