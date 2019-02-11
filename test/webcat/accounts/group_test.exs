defmodule WebCAT.Accounts.GroupTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.Group

  test "changeset/2 behaves as expected" do
    assert Group.changeset(%Group{}, Factory.params_with_assocs(:admin_group)).valid?
  end
end
