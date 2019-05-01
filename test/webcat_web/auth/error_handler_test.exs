defmodule WebCATWeb.Auth.ErrorHandlerTest do
  use WebCATWeb.ConnCase
  alias WebCAT.CRUD
  alias WebCAT.Accounts.User
  import WebCATWeb.Auth.Guardian

  describe "auth_error/3" do
    test "it handles the resource disappearing randomly", %{conn: conn} do
      user = Factory.insert(:user)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      CRUD.delete(User, user.id)

      response =
        conn
        |> put_req_header("authorization", "bearer: " <> token)
        |> get(Routes.user_path(conn, :index))
        |> json_response(401)

      assert Map.fetch!(response, "error") == "no_resource_found"
    end

    test "it handles the unauthenticated users", %{conn: conn} do
      response =
        conn
        |> get(Routes.user_path(conn, :index))
        |> json_response(401)

      assert Map.fetch!(response, "error") == "unauthenticated"
    end
  end
end
