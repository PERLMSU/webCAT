defmodule WebCATWeb.ExplanationControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      feedback = Factory.insert(:feedback)
      Factory.insert_list(3, :explanation, feedback: feedback)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.explanation_path(conn, :index, feedback_id: feedback.id))
        |> json_response(200)

      assert Enum.count(result) == 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.explanation_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      explanation = Factory.insert(:explanation)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.explanation_path(conn, :show, explanation.id))
        |> json_response(200)

      assert res["data"]["id"] == to_string(explanation.id)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:explanation)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.explanation_path(conn, :create), data)
        |> json_response(201)

      assert res["data"]["attributes"]["content"] == data["content"]
    end

    test "doesn't allow normal users to create explanations", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.explanation_path(conn, :create), Factory.string_params_for(:explanation))
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update =
        Factory.string_params_for(:explanation)
        |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.explanation_path(conn, :update, Factory.insert(:explanation).id), update)
        |> json_response(200)

      assert res["data"]["attributes"]["content"] == update["content"]
    end

    test "doesn't allow normal users to update explanations", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:explanation)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.explanation_path(conn, :update, Factory.insert(:explanation).id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.explanation_path(conn, :delete, Factory.insert(:explanation).id))
      |> json_response(200)
    end

    test "doesn't allow normal users to delete explanations", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.explanation_path(conn, :delete, Factory.insert(:explanation).id))
      |> json_response(403)
    end
  end

  defp login_admin() do
    user = Factory.insert(:admin)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end

  defp login_user() do
    user = Factory.insert(:user)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end
end
