defmodule WebCATWeb.CategoryControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of categories", %{conn: conn, user: user} do
      classroom = Factory.insert(:classroom)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.category_path(conn, :index, classroom.id))
        |> html_response(200)

      assert response =~ "Categories"
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays category", %{conn: conn, user: user} do
      data = Factory.insert(:category)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.category_path(conn, :show, data.classroom_id, data.id))
        |> html_response(200)

      assert response =~ data.name
      assert response =~ data.description

      assert response =~ "Sub Categories"
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a category", %{conn: conn, user: user} do
      classroom = Factory.insert(:classroom)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.category_path(conn, :new, classroom.id))
        |> html_response(200)

      assert response =~ "New Category"
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates category", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:category)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.category_path(conn, :create, data.classroom_id), %{category: data})
        |> redirected_to(302)

      assert Regex.match?(
               ~r/#{Routes.category_path(conn, :index, data.classroom_id)}\/\d+/,
               redirect
             )
    end

    test "renders form errors if create fails", %{conn: conn, user: user} do
      inserted = Factory.insert(:category)
      data = Factory.params_with_assocs(:category, name: inserted.name)

      response =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.category_path(conn, :create, data.classroom_id), %{category: data})
        |> html_response(200)

      assert response =~ "New Category"
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a category", %{conn: conn, user: user} do
      data = Factory.insert(:category)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.category_path(conn, :edit, data.classroom_id, data.id))
        |> html_response(200)

      assert response =~ "Edit Category"
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a category", %{conn: conn, user: user} do
      data = Factory.insert(:category)
      update = Factory.params_with_assocs(:category)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.category_path(conn, :update, data.classroom_id, data.id), %{
          category: update
        })
        |> redirected_to(302)

      assert redirect =~ Routes.category_path(conn, :show, data.classroom_id, data.id)
    end

    test "renders form errors if create fails", %{conn: conn, user: user} do
      inserted = Factory.insert(:category)
      data = Factory.insert(:category)
      update = Factory.params_with_assocs(:category, name: inserted.name)

      response =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.category_path(conn, :update, data.classroom_id, data.id), %{category: update})
        |> html_response(200)

      assert response =~ "Edit Category"
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a category", %{conn: conn, user: user} do
      data = Factory.insert(:category)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.category_path(conn, :delete, data.classroom_id, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.category_path(conn, :index, data.classroom_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
