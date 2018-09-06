defmodule WebCAT.Accounts.UsersTest do
  @moduledoc false
  
  use WebCAT.DataCase, async: true
  use Bamboo.Test

  alias WebCAT.Accounts.{Users, Confirmation}
  alias WebCAT.Repo

  describe "get/1" do
    test "behaves as expected" do
      inserted = Factory.insert(:user)

      {:ok, user} = Users.get(inserted.id)
      assert user.id == inserted.id
      assert user.email == inserted.email

      {:error, :not_found} = Users.get(123_456)
    end
  end

  describe "update/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:user)
      update = Factory.params_for(:user)
      {:ok, user} = Users.update(inserted.id, update)

      assert user.id == inserted.id
      assert user.first_name == update.first_name
      assert user.last_name == update.last_name
      assert user.middle_name == update.middle_name
      assert user.email == update.email
      assert user.username == update.username
      assert user.nickname == update.nickname
      assert user.bio == update.bio
      assert user.phone == update.phone
      assert user.city == update.city
      assert user.state == update.state
      assert user.country == update.country
      assert user.birthday == Date.from_iso8601!(update.birthday)
      assert user.active == update.active
      assert user.role == update.role

      {:error, :not_found} = Users.update(123_456, update)
    end

    test "fails on changeset errors" do
      # TODO
    end
  end

  describe "login/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:user)

      {:ok, user} = Users.login(inserted.email, "password")

      assert inserted.email == user.email

      {:error, :unauthorized} = Users.login(inserted.email, "password1")
      {:error, :unauthorized} = Users.login("email@email.edm", "password")
    end
  end

  describe "create/2" do
    test "behaves as expected" do
      params = Factory.params_for(:user, password: "password")

      {:ok, user} = Users.create(params)
      {:ok, logged_in} = Users.login(user.email, "password")

      assert user.id == logged_in.id
      assert user.email == logged_in.email

      email = WebCAT.Email.confirmation(user.email, Repo.get_by(Confirmation, user_id: user.id).token)
      assert_delivered_email email
    end
  end

  describe "rotation_groups/1" do
    test "behaves as expected" do
      Factory.insert_list(5, :rotation_group)
      user = Factory.insert(:user, rotation_groups: Factory.insert_list(4, :rotation_group))

      {:ok, groups} = Users.rotation_groups(user.id)
      assert Enum.count(groups) == 4
    end
  end

  describe "notification/1" do
    test "behaves as expected" do
      Factory.insert_list(5, :notification)
      user = Factory.insert(:user, notifications: Factory.insert_list(4, :notification))

      {:ok, notifications} = Users.notifications(user.id)
      assert Enum.count(notifications) == 4
    end
  end

  describe "classrooms/1" do
    test "behaves as expected" do
      Factory.insert_list(5, :classroom)
      user = Factory.insert(:user, classrooms: Factory.insert_list(4, :classroom))

      {:ok, classrooms} = Users.classrooms(user.id)
      assert Enum.count(classrooms) == 4
    end
  end
end
