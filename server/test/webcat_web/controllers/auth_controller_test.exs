defmodule WebCATWeb.AuthControllerTest do
  @moduledoc false

  use WebCATWeb.ConnCase, async: true

  describe "login/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.insert(:user)

      response =
        conn
        |> post(Helpers.auth_path(conn, :login), %{email: user.email, password: "password"})
        |> json_response(201)

      assert Map.has_key?(response, "token")
    end
  end

  describe "signup/2" do
    test "behaves as expected", %{conn: conn} do
      user = Factory.string_params_for(:user)

      response =
        conn
        |> post(Helpers.auth_path(conn, :signup), user)
        |> json_response(201)

      assert Map.has_key?(response, "token")
    end
  end
end
