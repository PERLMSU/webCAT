defmodule WebCATWeb.FeedbackControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with a table of feedback", %{conn: conn, user: user} do
      observation = Factory.insert(:feedback).observation

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.feedback_path(conn, :index, observation.id))
        |> html_response(200)

      assert response =~ "Feedback"
    end
  end

  describe "show/2" do
    setup ~w(login_user)a

    test "displays feedback", %{conn: conn, user: user} do
      data = Factory.insert(:feedback)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.feedback_path(conn, :show, data.observation_id, data.id))
        |> html_response(200)

      assert response =~ data.content
    end
  end

  describe "new/2" do
    setup ~w(login_user)a

    test "shows the form to create feedback", %{conn: conn, user: user} do
      observation = Factory.insert(:observation)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.feedback_path(conn, :new, observation.id))
        |> html_response(200)

      assert response =~ "New Feedback"
    end
  end

  describe "create/2" do
    setup ~w(login_user)a

    test "creates feedback", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:feedback)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.feedback_path(conn, :create, data.observation_id), %{feedback: data})
        |> redirected_to(302)

      assert Regex.match?(
               ~r/#{Routes.feedback_path(conn, :index, data.observation_id)}\/\d+/,
               redirect
             )
    end

    test "renders form errors if create fails", %{conn: conn, user: user} do
      data = Factory.params_with_assocs(:feedback) |> Map.drop(~w(content)a)

      response =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.feedback_path(conn, :create, data.observation_id), %{feedback: data})
        |> html_response(200)

      assert response =~ "New Feedback"
    end
  end

  describe "edit/2" do
    setup ~w(login_user)a

    test "shows the form to update feedback", %{conn: conn, user: user} do
      data = Factory.insert(:feedback)

      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.feedback_path(conn, :edit, data.observation_id, data.id))
        |> html_response(200)

      assert response =~ "Edit Feedback"
    end
  end

  describe "update/2" do
    setup ~w(login_user)a

    test "updates feedback", %{conn: conn, user: user} do
      data = Factory.insert(:feedback)
      update = Factory.params_with_assocs(:feedback)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.feedback_path(conn, :update, data.observation_id, data.id), %{
          feedback: update
        })
        |> redirected_to(302)

      assert redirect =~ Routes.feedback_path(conn, :show, data.observation_id, data.id)
    end

    test "shows form if update fails", %{conn: conn, user: user} do
      data = Factory.insert(:feedback)
      update = Factory.params_with_assocs(:feedback) |> Map.put(:content, nil)

      response =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.feedback_path(conn, :update, data.observation_id, data.id), %{
          feedback: update
        })
        |> html_response(200)

      assert response =~ "Edit Feedback"
    end
  end

  describe "delete/2" do
    setup ~w(login_user)a

    test "deletes feedback", %{conn: conn, user: user} do
      data = Factory.insert(:feedback)

      redirect =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.feedback_path(conn, :delete, data.observation_id, data.id))
        |> redirected_to(302)

      assert redirect =~ Routes.feedback_path(conn, :index, data.observation_id)
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
