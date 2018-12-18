defmodule WebCAT.Accounts.UsersTest do
  @moduledoc false

  use WebCAT.DataCase, async: true
  use Bamboo.Test

  alias WebCAT.Accounts.{Users, Confirmation}
  alias WebCAT.Repo

  test "login/2 behaves as expected" do
    inserted = Factory.insert(:user)

    {:ok, user} = Users.login(inserted.email, "password")

    assert inserted.email == user.email

    {:error, :unauthorized} = Users.login(inserted.email, "password1")
    {:error, :unauthorized} = Users.login("email@email.edm", "password")
  end

  test "create/2 behaves as expected" do
    params = Factory.params_for(:user, password: "password")

    {:ok, user} = Users.create(params)
    {:ok, logged_in} = Users.login(user.email, "password")

    assert user.id == logged_in.id
    assert user.email == logged_in.email

    email =
      WebCAT.Email.confirmation(user.email, Repo.get_by(Confirmation, user_id: user.id).token)

    assert_delivered_email(email)
  end

  test "notification/1 behaves as expected" do
    Factory.insert_list(5, :notification)
    user = Factory.insert(:user, notifications: Factory.insert_list(4, :notification))

    notifications = Users.notifications(user.id)
    assert Enum.count(notifications) == 4
  end

  test "classrooms/1 behaves as expected" do
    Factory.insert_list(5, :classroom)
    user = Factory.insert(:user, classrooms: Factory.insert_list(4, :classroom))

    classrooms = Users.classrooms(user.id)
    assert Enum.count(classrooms) == 4
  end
end
