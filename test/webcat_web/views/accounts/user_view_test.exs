defmodule WebCATWeb.UserViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.UserView

  describe "render/2" do
    test "it renders a user properly" do
      user = Factory.insert(:user)
      rendered = UserView.render("show.json", user: user)

      assert rendered[:id] == user.id
      assert rendered[:first_name] == user.first_name
      assert rendered[:last_name] == user.last_name
      assert rendered[:email] == user.email
    end

    test "it renders a list of users properly" do
      users = Factory.insert_list(3, :user)
      rendered_list = UserView.render("list.json", users: users)
      assert Enum.count(rendered_list) == 3
    end
  end
end
