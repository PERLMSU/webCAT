defmodule WebCATWeb.UserSocketTest do
  use WebCATWeb.ChannelCase

  setup do
    {:ok, socket: socket(WebCATWeb.UserSocket, "user_id", %{some: :assign})}
  end

  describe "connect/2" do
    test "behaves correctly", %{socket: socket} do
      flunk("Test needs to be written")
    end

    test "denies an unauthenticated user", %{socket: socket} do
      flunk("Test needs to be written")
    end
  end

  describe "id/1" do
    test "behaves correctly", %{socket: socket} do
      flunk("Test needs to be written")
    end
  end
end
