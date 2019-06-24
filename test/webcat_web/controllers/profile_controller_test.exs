defmodule WebCATWeb.ProfileControllerTest do
  use WebCATWeb.ConnCase

  describe "show/2" do
    test "responds normally to a well formed login request", %{conn: conn} do
      {:ok, user} = login_user()

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.profile_path(conn, :show))
        |> json_response(200)

      assert result["id"] == user.id
    end
  end

  describe "update/2" do
    test "responds normally to a well formed login request", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:user)

      result =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.profile_path(conn, :update), update)
        |> json_response(200)

      assert result["email"] == update["email"]
      assert result["email"] != user.email
    end
  end

  defp login_user() do
    user = Factory.insert(:admin)
    Factory.insert(:password_credential, user: user)
    {:ok, user}
  end
end
