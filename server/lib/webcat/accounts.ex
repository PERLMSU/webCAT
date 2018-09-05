defmodule WebCAT.Accounts do
  alias WebCAT.Accounts.User

  @behaviour Bodyguard.Policy

  def authorize(:list_users, _user, _), do: :ok

  def authorize(:show_user, _user, _subject_user), do: :ok

  @doc """
  Administrators have full privileges
  """
  def authorize(_, %User{role: "admin"}, %User{role: "instructor"}), do: :ok

  @doc """
  Users can update their own details, list their own notifications/classrooms/rotation_groups
  """
  def authorize(action, %User{id: user_id}, %User{id: user_id})
      when action in ~w(update_user delete_user list_notifications list_classrooms list_rotation_groups)a,
      do: :ok

  @doc """
  Deny catch-all
  """
  def authorize(_, _, _), do: false
end
