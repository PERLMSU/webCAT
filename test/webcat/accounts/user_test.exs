defmodule WebCAT.Accounts.UserTest do
  @moduledoc false
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.User

  describe "changeset/2" do
    test "behaves as expected" do
      assert User.changeset(%User{}, Factory.params_for(:user)).valid?
      refute User.changeset(%User{}, Factory.params_for(:user, first_name: nil)).valid?
    end
  end
end
