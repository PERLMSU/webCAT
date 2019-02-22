defmodule WebCATWeb.ObservationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of observations", %{conn: conn, user: user} do
      category = Factory.insert(:category)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.observation_path(conn, :index, category.id))
        |> html_response(200)

      assert response =~ "Observations"
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays observation", %{conn: conn, user: user} do
      data = Factory.insert(:observation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.observation_path(conn, :show, data.category_id, data.id))
        |> html_response(200)

      assert response =~ data.content

      assert response =~ "Feedback"
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create a observation", %{conn: conn, user: user} do
      category = Factory.insert(:category)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.observation_path(conn, :new, category.id))
        |> html_response(200)

      assert response =~ "New Observation"
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates observation", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:observation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.observation_path(conn, :create, data.category_id), %{observation: data})
        |> redirected_to(302)

      assert Regex.match?(
               ~r/#{Routes.observation_path(conn, :index, data.category_id)}\/\d+/,
               redirect
             )
    end

    test "renders form errors if create fails", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:observation) |> Map.drop(~w(content)a)

      response =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.observation_path(conn, :create, data.category_id), %{observation: data})
        |> html_response(200)

      assert response =~ "New Observation"
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update a observation", %{conn: conn, user: user} do
      data = Factory.insert(:observation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.observation_path(conn, :edit, data.category_id, data.id))
        |> html_response(200)

      assert response =~ "Edit Observation"
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates a observation", %{conn: conn, user: user} do
      data = Factory.insert(:observation)
      update = Factory.params_with_assocs(:observation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.observation_path(conn, :update, data.category_id, data.id), %{
          observation: update
        })
        |> redirected_to(302)

      assert redirect =~ Routes.observation_path(conn, :show, data.category_id, data.id)
    end

    test "shows form if update fails", %{conn: conn, user: user} do
      data = Factory.insert(:observation)
      update = Factory.params_with_assocs(:observation) |> Map.put(:content, nil)

      response =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.observation_path(conn, :update, data.category_id, data.id), %{
          observation: update
        })
        |> html_response(200)

      assert response =~ "Edit Observation"
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes a observation", %{conn: conn, user: user} do
      data = Factory.insert(:observation)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.observation_path(conn, :delete, data.category_id, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.observation_path(conn, :index, data.category_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
