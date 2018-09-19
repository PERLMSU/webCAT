defmodule WebCATWeb.ResetControllerTest do
  @moduledoc false

  use WebCATWeb.ConnCase, async: true

  describe "show/2" do
    test "behaves as expected", %{conn: conn} do
      reset = Factory.insert(:password_reset)

      conn
      |> get(Helpers.reset_path(conn, :show, reset.token))
      |> response(200)
    end
  end

  describe "update/2" do
    test "behaves as expected", %{conn: conn} do
      reset = Factory.insert(:password_reset)

      conn
      |> patch(Helpers.reset_path(conn, :update, reset.token), %{"password" => "password1"})
      |> response(200)
    end
  end
end
