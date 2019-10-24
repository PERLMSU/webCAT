defmodule WebCATWeb.SectionControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      classroom = Factory.insert(:classroom)
      Factory.insert_list(3, :section, classroom: classroom)

      result =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.section_path(conn, :index, filter: %{classroom_id: classroom.id}))
        |> json_response(:ok)

      assert Enum.count(result["data"]) == 3
    end

    test "fails when a user isn't authenticated", %{conn: conn} do
      conn
      |> get(Routes.section_path(conn, :index))
      |> json_response(:unauthorized)
    end
  end

  describe "show/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_user()

      id = Factory.insert(:section).id

      res =
        conn
        |> Auth.sign_in(user)
        |> get(Routes.section_path(conn, :show, id))
        |> json_response(:ok)

      assert res["data"]["id"] == to_string(id)
    end
  end

  describe "create/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.string_params_with_assocs(:section) |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.section_path(conn, :create), data)
        |> json_response(:created)

      assert res["data"]["attributes"]["number"] == data["number"]
    end

    test "doesn't allow normal users to create", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> post(Routes.section_path(conn, :create), Factory.string_params_for(:section))
      |> json_response(:forbidden)
    end
  end

  describe "update/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      update = Factory.string_params_for(:section) |> Map.drop(~w(users))

      res =
        conn
        |> Auth.sign_in(user)
        |> put(Routes.section_path(conn, :update, Factory.insert(:section).id), update)
        |> json_response(:ok)

      assert res["data"]["attributes"]["number"] == update["number"]
    end

    test "doesn't allow normal users to update", %{conn: conn} do
      {:ok, user} = login_user()

      update = Factory.string_params_for(:section)

      conn
      |> Auth.sign_in(user)
      |> put(Routes.section_path(conn, :update, Factory.insert(:section).id), update)
      |> json_response(:forbidden)
    end
  end

  describe "delete/3" do
    test "responds normally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:section)

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.section_path(conn, :delete, data.id))
      |> response(:no_content)

      conn
      |> Auth.sign_in(user)
      |> get(Routes.section_path(conn, :show, data.id))
      |> json_response(:not_found)
    end

    test "doesn't allow normal users to delete", %{conn: conn} do
      {:ok, user} = login_user()

      conn
      |> Auth.sign_in(user)
      |> delete(Routes.section_path(conn, :delete, Factory.insert(:section).id))
      |> json_response(:forbidden)
    end
  end

  describe "import/3" do
    test "responds nromally to a well formed request", %{conn: conn} do
      {:ok, user} = login_admin()

      data = Factory.insert(:section)

      upload = %Plug.Upload{
        path: Path.join(__DIR__, "../../support/import.xlsx"),
        filename: "import.xlsx"
      }
      assert File.exists?(upload.path)

      res =
        conn
        |> Auth.sign_in(user)
        |> post(Routes.section_path(conn, :import, data.id), %{file: upload})
        |> json_response(:created)

      assert Enum.count(res["data"]) == 2
    end

    test "doesn't allow normal users to import", %{conn: conn} do
      {:ok, user} = login_user()

      data = Factory.insert(:section)

      upload = %Plug.Upload{
        path: Path.join(__DIR__, "../../support/import.xlsx"),
        filename: "import.xlsx"
      }
      assert File.exists?(upload.path)

      conn
      |> Auth.sign_in(user)
      |> post(Routes.section_path(conn, :import, data.id), %{file: upload})
      |> json_response(:forbidden)
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
