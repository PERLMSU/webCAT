defmodule WebCATWeb.CommentControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      draft = Factory.insert(:draft)
      Factory.insert_list(3, :comment, draft: draft)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.comment_path(conn, :index, draft.id))
        |> json_response(200)

      assert Enum.count(result) >= 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.comment_path(conn, :index, Factory.insert(:draft).id))
      |> json_response(401)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      comment = Factory.insert(:comment)

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.comment_path(conn, :show, comment.draft_id, comment.id))
        |> json_response(200)

      assert res["id"] == comment.id
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:comment)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.comment_path(conn, :create, data["draft_id"]), data)
        |> json_response(201)

      assert res["name"] == data["name"]
    end

    test "doesn't allow normal users to create comments", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.string_params_with_assocs(:comment)

      conn
      |> Auth.sign_in(user)
      |> post(Routes.comment_path(conn, :create, data["draft_id"]), data)
      |> json_response(403)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:comment)
      update = Factory.string_params_with_assocs(:comment)

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.comment_path(conn, :update, data.draft_id, data.id), update)
        |> json_response(200)

      assert res["name"] == update["name"]
    end

    test "doesn't allow normal users to update comments", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert(:comment)
      update = Factory.string_params_for(:comment)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.comment_path(conn, :update, data.draft_id, data.id), update)
      |> json_response(403)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:comment)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.comment_path(conn, :delete, data.draft_id, data.id))
      |> text_response(204)
    end

    test "doesn't allow normal users to delete comments", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert(:comment)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.comment_path(conn, :delete, data.draft_id, data.id))
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
