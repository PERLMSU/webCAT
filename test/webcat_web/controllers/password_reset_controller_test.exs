defmodule WebCATWeb.PasswordResetControllerTest do
  use WebCATWeb.ConnCase

  describe "index/2" do
    test "displays password reset init form", %{conn: conn} do
      flunk("Test needs to be written")
    end
  end

  describe "create/2" do
    test "creates a password reset for an email address", %{conn: conn} do
      flunk("Test needs to be written")
    end
  end

  describe "reset/2" do
    test "redirects on faulty token", %{conn: conn} do
      flunk("Test needs to be written")
    end

    test "displays password reset form", %{conn: conn} do
      flunk("Test needs to be written")
    end
  end

  describe "finish_reset/2" do
    test "redirects on faulty token" do
      flunk("Test needs to be written")
    end

    test "finishes a reset successfully" do
      flunk("Test needs to be written")
    end
  end
end
