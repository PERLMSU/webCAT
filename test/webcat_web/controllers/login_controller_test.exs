defmodule WebCATWeb.LoginControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    test "displays login form", %{conn: conn} do
      flunk("Test needs to be written")
    end
  end

  describe "login/2" do
    test "redirects on faulty email or password", %{conn: conn} do
      flunk("Test needs to be written")
    end

    test "logs in a user", %{conn: conn} do
      flunk("Test needs to be written")
    end
  end

  describe "credential_login/2" do
    test "redirects on faulty token", %{conn: conn} do
      flunk("Test needs to be written")
    end

    test "logs in a user", %{conn: conn} do
      flunk("Test needs to be written")
    end
  end
end
