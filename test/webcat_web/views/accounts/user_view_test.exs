defmodule WebCATWeb.UserViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.UserView
  alias WebCAT.Accounts.User

  describe "render/2" do
    test "it renders a user properly", %{conn: conn} do
      user = Factory.insert(:admin)
      {:ok, user} = WebCAT.CRUD.get(User, user.id)
      rendered = UserView.show(user, conn, %{})
      data = rendered[:data]
      attributes = data[:attributes]

      assert data[:id] == to_string(user.id)
      assert attributes[:first_name] == user.first_name
      assert attributes[:last_name] == user.last_name
      assert attributes[:email] == user.email
    end

    test "it renders a list of users properly", %{conn: conn} do
      users = Factory.insert_list(3, :user)
      rendered_list = UserView.index(users, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
