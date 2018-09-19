defmodule WebCAT.Rotations do
  alias WebCAT.Accounts.User

  @behaviour Bodyguard.Policy

  def authorize(action, _user, _)
      when action in ~w(show_classroom list_classrooms list_classroom_instructors list_classroom_rotations list_classroom_students)a,
      do: true

  def authorize(action, _user, _)
      when action in ~w(show_rotation_group list_rotation_groups list_rotation_group_drafts list_rotation_group_students)a,
      do: true

  def authorize(action, _user, _)
      when action in ~w(show_rotation list_rotations list_rotation_students)a,
      do: true

  def authorize(action, _user, _)
      when action in ~w(show_semester list_semesters list_semester_classrooms)a,
      do: true

  def authorize(action, _user, _)
      when action in ~w(show_student list_students list_student_drafts list_student_notes list_student_rotation_groups)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_classroom update_classroom delete_classroom)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_rotation_group update_rotation_group delete_rotation_group)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_rotation update_rotation delete_rotation)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_semester update_semester delete_semester)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_student update_student delete_student)a,
      do: true

  @doc """
  Deny catch-all
  """
  def authorize(_, _, _), do: false
end
