defmodule WebCATWeb.ConfirmationControllerTest do
  @moduledoc false

  use WebCATWeb.ConnCase, async: true

  describe "show/2" do
    test "behaves as expected", %{conn: conn} do
      confirmation = Factory.insert(:confirmation)

      conn
      |> get(Helpers.confirmation_path(conn, :show, confirmation.token))
      |> response(200)
    end
  end

  describe "update/2" do
    test "behaves as expected", %{conn: conn} do
      confirmation = Factory.insert(:confirmation)

      conn
      |> patch(Helpers.confirmation_path(conn, :update, confirmation.token))
      |> response(200)
    end
  end
end
