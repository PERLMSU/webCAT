defmodule WebCATWeb.StudentFeedbackControllerTest do
  use WebCATWeb.ConnCase

  describe "classrooms/3" do
    setup ~w(login_user)a

    test "responds with the list of classrooms", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "sections/3" do
    setup ~w(login_user)a

    test "responds with the list of sections", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "groups/3" do
    setup ~w(login_user)a

    test "responds with the list of groups", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "students/3" do
    setup ~w(login_user)a

    test "responds with the list of students", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "categories/3" do
    setup ~w(login_user)a

    test "responds with the list of categories", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  describe "feedback/3" do
    setup ~w(login_user)a

    test "updates feedback", %{conn: conn, user: user} do
      flunk("Test needs to be written")
    end
  end

  defp login_user(_) do
    user = Factory.insert(:admin)
    {:ok, user: user}
  end
end
