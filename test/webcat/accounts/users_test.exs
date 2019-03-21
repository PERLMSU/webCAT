defmodule WebCAT.Accounts.UsersTest do
  @moduledoc false

  use WebCAT.DataCase, async: true
  use Bamboo.Test

  alias WebCAT.Accounts.{Users, TokenCredential}
  alias WebCAT.Repo

  test "login/2 behaves as expected" do
    credential = Factory.insert(:password_credential)

    {:ok, user} = Users.login(credential.user.email, "password")

    assert user.first_name == credential.user.first_name
    assert user.last_name == credential.user.last_name
    assert user.email == credential.user.email

    {:error, _} = Users.login(credential.user.email, "password1")
    {:error, _} = Users.login("email@email.edm", "password")
  end

  test "create/2 behaves as expected" do
    params = Factory.params_for(:user)

    {:ok, user} = Users.create(params)
    credential = Factory.insert(:password_credential, user: user)
    {:ok, logged_in} = Users.login(credential.user.email, "password")

    assert user.id == logged_in.id
    assert user.email == logged_in.email

    email =
      WebCATWeb.Email.confirmation(credential.user.email, Repo.get_by(TokenCredential, user_id: user.id).token)

    assert_delivered_email(email)
  end
end
