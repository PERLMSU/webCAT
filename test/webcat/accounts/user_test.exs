defmodule WebCAT.Accounts.UserTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.User
  alias WebCAT.Factory

  describe "changeset/2" do
    test "behaves as expected" do
      assert User.changeset(%User{}, Factory.params_for(:user)).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, first_name: nil)).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, email: "email")).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, phone: "(989) 992-91")).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, username: "wayToooooooLonngGGGggGGGGGGG")).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, state: "Michigan")).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, username: "invalid_chars_used@!")).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, role: "invalid_role")).valid?
    end

    @duplicate_email Factory.build(:user, email: "email@msu.edu")
    @duplicate_username Factory.build(:user, username: "user")

    test "honors unique constraints" do
      Repo.insert!(User.changeset(@duplicate_email))
      {:error, _} = Repo.insert(User.changeset(@duplicate_email))

      Repo.insert!(User.changeset(@duplicate_username))
      {:error, _} = Repo.insert(User.changeset(@duplicate_username))
    end
  end
end
