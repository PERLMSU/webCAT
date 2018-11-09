defmodule WebCATWeb.AccountsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.User

  describe "authorize/3" do
    test "any authenticated user can list and show users" do
      user = Factory.insert(:user)
      user2 = Factory.insert(:user)

      assert :ok == Bodyguard.permit(User, :list_users, user)
      assert :ok == Bodyguard.permit(User, :show_user, user, user2)
    end

    test "only admins can create accounts" do
      admin = Factory.insert(:user, role: "admin")
      user = Factory.insert(:user)

      assert :ok == Bodyguard.permit(User, :create_user, admin)
      assert {:error, :unauthorized} == Bodyguard.permit(User, :create_user, user)
    end

    test "allows admins full control over non-admins" do
      admin = Factory.insert(:user, role: "admin")
      admin2 = Factory.insert(:user, role: "admin")
      user = Factory.insert(:user)

      assert :ok == Bodyguard.permit(User, :update_user, admin, user)
      assert :ok == Bodyguard.permit(User, :delete_user, admin, user)
      assert :ok == Bodyguard.permit(User, :list_notifications, admin, user)
      assert :ok == Bodyguard.permit(User, :list_classrooms, admin, user)
      assert :ok == Bodyguard.permit(User, :list_rotation_groups, admin, user)

      #assert {:error, :unauthorized} ==
      #         Bodyguard.permit(User, :update_user, admin, admin2)

      #assert {:error, :unauthorized} ==
      #         Bodyguard.permit(User, :delete_user, admin, admin2)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :list_notifications, admin, admin2)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :list_classrooms, admin, admin2)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :list_rotation_groups, admin, admin2)
    end

    test "allows users full control over their own account and denies others" do
      user = Factory.insert(:user)
      user2 = Factory.insert(:user)

      assert :ok == Bodyguard.permit(User, :update_user, user, user)
      assert :ok == Bodyguard.permit(User, :list_notifications, user, user)
      assert :ok == Bodyguard.permit(User, :list_classrooms, user, user)
      assert :ok == Bodyguard.permit(User, :list_rotation_groups, user, user)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :update_user, user, user2)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :delete_user, user, user2)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :list_notifications, user, user2)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :list_classrooms, user, user2)

      assert {:error, :unauthorized} ==
               Bodyguard.permit(User, :list_rotation_groups, user, user2)
    end
  end
end
