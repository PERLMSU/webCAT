defmodule WebCATWeb.DraftControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      parent = Factory.insert(:group_draft)
      Factory.insert_list(3, :student_draft, parent_draft: parent)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.draft_path(conn, :index, parent_draft_id: parent.id))
        |> json_response(200)

      assert Enum.count(result) == 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.draft_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      draft = Factory.insert(:student_draft)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.draft_path(conn, :show, draft.id))
        |> json_response(200)

      assert res["data"]["id"] == to_string(draft.id)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:student_draft)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.draft_path(conn, :create), data)
        |> json_response(201)

      assert res["data"]["attributes"]["content"] == data["content"]
    end

    test "doesn't allow normal users to create drafts", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.draft_path(conn, :create), Factory.string_params_for(:student_draft))
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update = Factory.string_params_with_assocs(:student_draft)

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.draft_path(conn, :update, Factory.insert(:student_draft).id), update)
        |> json_response(200)

      assert res["data"]["attributes"]["content"] == update["content"]
    end

    test "doesn't allow normal users to update drafts", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:student_draft)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.draft_path(conn, :update, Factory.insert(:student_draft).id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.draft_path(conn, :delete, Factory.insert(:student_draft).id))
      |> json_response(200)
    end

    test "doesn't allow normal users to delete drafts", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.draft_path(conn, :delete, Factory.insert(:student_draft).id))
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
