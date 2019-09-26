defmodule WebCATWeb.UserViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.UserView

  describe "render/2" do
    test "it renders a user properly", %{conn: conn} do
      user = Factory.insert(:user)
      rendered = UserView.show(user, conn, %{})[:data]

      assert rendered[:id] == to_string(user.id)
      assert rendered[:attributes][:first_name] == user.first_name
      assert rendered[:attributes][:last_name] == user.last_name
      assert rendered[:attributes][:email] == user.email
    end

    test "it renders a list of users properly", %{conn: conn} do
      users = Factory.insert_list(3, :user)
      rendered_list = UserView.index(users, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
