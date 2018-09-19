defmodule WebCAT.Accounts do
  alias WebCAT.Accounts.User

  @behaviour Bodyguard.Policy

  def authorize(action, _user, _subject_user) when action in ~w(list_users show_user)a, do: true

  @doc """
  Only administrators can create accounts
  """
  def authorize(:create_user, %User{role: "admin"}, _), do: true

  @doc """
  Administrators have full privileges over non-administrators
  """
  def authorize(_, %User{role: "admin"}, %User{role: "instructor"}), do: true

  @doc """
  Users can update their own details, list their own notifications/classrooms/rotation_groups
  """
  def authorize(action, %User{id: user_id}, %User{id: user_id})
      when action in ~w(update_user delete_user list_notifications list_classrooms list_rotation_groups)a,
      do: true

  @doc """
  Deny catch-all
  """
  def authorize(_, _, _), do: false
end
