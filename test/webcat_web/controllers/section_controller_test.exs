defmodule WebCATWeb.SectionControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of sections", %{conn: conn, user: user} do
      semester = Factory.insert(:semester)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.section_path(conn, :index, semester.id))
        |> html_response(200)

      assert response =~ "Sections"
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays section", %{conn: conn, user: user} do
      data = Factory.insert(:section)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.section_path(conn, :show, data.semester_id, data.id))
        |> html_response(200)

      assert response =~ data.number
      assert response =~ data.description

      assert response =~ "Rotations"
      assert response =~ "Users"
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a section", %{conn: conn, user: user} do
      semester = Factory.insert(:semester)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.section_path(conn, :new, semester.id))
        |> html_response(200)

      assert response =~ "New Section"
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates section", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:section)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.section_path(conn, :create, data.semester_id), %{section: data})
        |> redirected_to(302)

      assert Regex.match?(
               ~r/#{Routes.section_path(conn, :index, data.semester_id)}\/\d+/,
               redirect
             )
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a section", %{conn: conn, user: user} do
      data = Factory.insert(:section)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.section_path(conn, :edit, data.semester_id, data.id))
        |> html_response(200)

      assert response =~ "Edit Section"
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a section", %{conn: conn, user: user} do
      data = Factory.insert(:section)
      update = Factory.params_with_assocs(:section)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.section_path(conn, :update, data.semester_id, data.id), %{
          section: update
        })
        |> redirected_to(302)

      assert redirect =~ Routes.section_path(conn, :show, data.semester_id, data.id)
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a section", %{conn: conn, user: user} do
      data = Factory.insert(:section)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.section_path(conn, :delete, data.semester_id, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.section_path(conn, :index, data.semester_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
