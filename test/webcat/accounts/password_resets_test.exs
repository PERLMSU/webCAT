defmodule WebCATWeb.Accounts.PasswordResetsTest do
  @moduledoc false

  use WebCAT.DataCase, async: true
  use Bamboo.Test

  alias WebCAT.Accounts.{PasswordResets, Users}

  describe "start_reset/1" do
    test "behaves as expected" do
      user = Factory.insert(:user)
      {:ok, reset} = PasswordResets.start_reset(user.email)

      assert reset.user_id == user.id

      email = WebCAT.Email.password_reset(user.email, reset.token)
      assert_delivered_email(email)
    end
  end

  describe "get/1" do
    test "behaves as expected" do
      reset = Factory.insert(:password_reset)

      {:ok, found} = PasswordResets.get(reset.token)
      assert found.id == reset.id
    end
  end

  describe "finish_reset/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:user)
      reset = Factory.insert(:password_reset, user: inserted)

      {:ok, _} = Users.login(inserted.email, "password")
      {:ok, user} = PasswordResets.finish_reset(reset.token, "password1")
      assert user.id == inserted.id
      assert user.email == inserted.email

      # Ensure the password has been changed
      {:ok, _} = Users.login(user.email, "password1")
      {:error, :unauthorized} = Users.login(user.email, "password")

      # Ensure it can't be changed twice with the same token
      {:error, :not_found} = PasswordResets.finish_reset(reset.token, "password")
    end
  end
end
