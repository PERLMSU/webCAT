defmodule WebCAT.Accounts.UsersTest do
  @moduledoc false

  use WebCAT.DataCase, async: true
  use Bamboo.Test

  alias WebCAT.Accounts.{Users, TokenCredential}
  alias WebCAT.Repo

  test "login/2 behaves as expected" do
    credential = Factory.insert(:password_credential)

    {:ok, user} = Users.login(credential.email, "password")

    assert user.first_name == credential.user.first_name

    {:error, :unauthorized} = Users.login(credential.email, "password1")
    {:error, :unauthorized} = Users.login("email@email.edm", "password")
  end

  test "create/2 behaves as expected" do
    params = Factory.params_for(:user)

    {:ok, user} = Users.create(params)
    credential = Factory.insert(:password_credential, user: user)
    {:ok, logged_in} = Users.login(credential.email, "password")

    assert user.id == logged_in.id
    assert user.email == logged_in.email

    email =
      WebCAT.Email.confirmation(credential.email, Repo.get_by(TokenCredential, user_id: user.id).token)

    assert_delivered_email(email)
  end

  test "notification/1 behaves as expected" do
    Factory.insert_list(5, :notification)
    user = Factory.insert(:user, notifications: Factory.insert_list(4, :notification))

    notifications = Users.notifications(user.id)
    assert Enum.count(notifications) == 4
  end
end
