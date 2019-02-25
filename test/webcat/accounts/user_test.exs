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

  describe "by_role/1" do
    test "behaves as expected" do
      group =
        Factory.insert(:rotation_group)
        |> Repo.preload(users: [performer: ~w(roles)a])

      by_role = User.by_role(group.users)

      assert Enum.count(group.users) ==
               Enum.count(by_role["student"]) + Enum.count(by_role["assistant"])

      assert Enum.count(by_role["student"]) == 2
      assert Enum.count(by_role["assistant"]) == 1
    end
  end
end
