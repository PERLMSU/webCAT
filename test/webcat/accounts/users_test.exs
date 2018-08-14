defmodule WebCAT.Accounts.UsersTest do
  use WebCAT.DataCase, async: true
  use Bamboo.Test

  alias WebCAT.Accounts.{Users, Confirmation}
  alias WebCAT.Factory
  alias WebCAT.Repo

  describe "get/1" do
    test "behaves as expected" do
      inserted = Factory.insert(:user)

      {:ok, user} = Users.get(inserted.id)
      assert user.id == inserted.id
      assert user.first_name == inserted.first_name
      assert user.last_name == inserted.last_name
      assert user.middle_name == inserted.middle_name
      assert user.email == inserted.email
      assert user.username == inserted.username
      assert user.nickname == inserted.nickname
      assert user.bio == inserted.bio
      assert user.phone == inserted.phone
      assert user.city == inserted.city
      assert user.state == inserted.state
      assert user.country == inserted.country
      assert user.birthday == inserted.birthday
      assert user.active == inserted.active
      assert user.role == inserted.role

      {:error, :not_found, _} = Users.get(123_456)
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
      assert user.birthday == update.birthday
      assert user.active == update.active
      assert user.role == update.role

      {:error, :not_found, _} = Users.update(123_456, update)
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

      {:error, :unauthorized, _} = Users.login(inserted.email, "password1")
      {:error, :unauthorized, _} = Users.login("email@email.edm", "password")
    end
  end

  describe "signup/2" do
    test "behaves as expected" do
      params = Factory.params_for(:user, password: "password")

      {:ok, user} = Users.signup(params)
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

      groups = Users.rotation_groups(user.id)
      assert Enum.count(groups) == 4
    end
  end

  describe "notification/1" do
    test "behaves as expected" do
      Factory.insert_list(5, :notification)
      user = Factory.insert(:user, notifications: Factory.insert_list(4, :notification))

      notifications = Users.notifications(user.id)
      assert Enum.count(notifications) == 4
    end
  end

  describe "classrooms/1" do
    test "behaves as expected" do
      Factory.insert_list(5, :classroom)
      user = Factory.insert(:user, classrooms: Factory.insert_list(4, :classroom))

      classrooms = Users.classrooms(user.id)
      assert Enum.count(classrooms) == 4
    end
  end

  describe "confirm/1" do
    test "behaves as expected" do
      inserted = Factory.insert(:confirmation)

      {:ok, confirmation} = Users.confirm(inserted.token)
      assert confirmation.verified
      assert confirmation.user_id == inserted.user_id
      assert confirmation.token == inserted.token
    end
  end

  describe "start_reset/1" do
    test "behaves as expected" do
      user = Factory.insert(:user)
      {:ok, reset} = Users.start_reset(user.id)

      assert reset.user_id == user.id

      email = WebCAT.Email.password_reset(user.email, reset.token)
      assert_delivered_email email
    end
  end

  describe "reset/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:user)
      reset = Factory.insert(:password_reset, user: inserted)

      {:ok, _} = Users.login(inserted.email, "password")
      {:ok, user} = Users.reset(reset.token, "password1")
      assert user.id == inserted.id
      assert user.email == inserted.email

      # Ensure the password has been changed
      {:ok, _} = Users.login(user.email, "password1")
      {:error, :unauthorized, _} = Users.login(user.email, "password")

      # Ensure it can't be changed twice with the same token
      {:error, :not_found, _} = Users.reset(reset.token, "password")
    end
  end
end
