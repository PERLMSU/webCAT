defmodule WebCATWeb.IndexControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    setup ~w(login_user)a

    test "responds with the dashboard", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.index_path(conn, :index))
        |> html_response(200)

      assert response =~ "Stats"
      assert response =~ "Students"
      assert response =~ "Observations"
      assert response =~ "Feedback Emails Sent"
      assert response =~ "Users"
    end
  end

  describe "changes/2" do
    setup ~w(login_user)a

    test "responds with the changelog", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.index_path(conn, :changes))
        |> html_response(200)

      assert response =~ "Changelog"
      # Just something that's only on this page
      assert response =~ "Keep a Changelog"
    end
  end

  describe "import/2" do
    setup ~w(login_user)a

    test "responds with the import prompt", %{conn: conn, user: user} do
      response =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.index_path(conn, :import))
        |> html_response(200)

      assert response =~ "Choose a file to import"
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
