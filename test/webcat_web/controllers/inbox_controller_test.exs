defmodule WebCATWeb.InboxControllerTest do
  use WebCATWeb.ConnCase

  describe "index/3" do
    setup ~w(login_user)a

    test "responds with the list of drafts", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "show/3" do
    setup ~w(login_user)a

    test "shows a single draft", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "new/3" do
    setup ~w(login_user)a

    test "displays form to create a new draft", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "create/3" do
    setup ~w(login_user)a

    test "creates a new draft", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "edit/3" do
    setup ~w(login_user)a

    test "displays form to edit a draft", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "update/3" do
    setup ~w(login_user)a

    test "updates a draft", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
