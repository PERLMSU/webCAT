defmodule WebCATWeb.Accounts.PasswordResetsTest do
  @moduledoc false

  use WebCAT.DataCase, async: true
  use Bamboo.Test

  alias WebCAT.Accounts.{PasswordResets, Users}

  test "start_reset/1 behaves as expected" do
    credential = Factory.insert(:password_credential)
    {:ok, reset} = PasswordResets.start_reset(credential.email)

    assert reset.user_id == credential.user_id

    email = WebCAT.Email.password_reset(credential.email, reset.token)
    assert_delivered_email(email)
  end

  test "get/1 behaves as expected" do
    reset = Factory.insert(:password_reset)

    {:ok, found} = PasswordResets.get(reset.token)
    assert found.id == reset.id
  end

  test "finish_reset/2 behaves as expected" do
    credential = Factory.insert(:password_credential)
    reset = Factory.insert(:password_reset, user: credential.user)

    {:ok, _} = Users.login(credential.email, "password")
    {:ok, user} = PasswordResets.finish_reset(reset.token, "password1")
    assert user.id == credential.user_id

    # Ensure the password has been changed
    {:ok, _} = Users.login(credential.email, "password1")
    {:error, _} = Users.login(credential.email, "password")

    # Ensure it can't be changed twice with the same token
    {:error, _} = PasswordResets.finish_reset(reset.token, "password")
  end
end
