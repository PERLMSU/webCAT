defmodule WebCATWeb.ImportControllerTest do
  use WebCATWeb.ConnCase

  @test_sheet Path.join(__DIR__, "../support/test_sheet.xlsx")
  setup_all do
    Application.ensure_all_started(:webcat)
    :ok
  end

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.import_path(conn, :index))
        |> json_response(200)

      assert Enum.count(result) == 0
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.import_path(conn, :index))
      |> json_response(401)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      assert File.exists?(@test_sheet)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.import_path(conn, :create), %{"import" => %Plug.Upload{path: @test_sheet}})
        |> text_response(201)

      assert res == ""
    end

    test "doesn't allow normal users to import", %{conn: conn} do
      {:ok, user} = login_user()

      assert File.exists?(@test_sheet)

      conn
      |> Auth.sign_in(user)
      |> post(Routes.import_path(conn, :create), %{"import" => %Plug.Upload{path: @test_sheet}})
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
