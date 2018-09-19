defmodule WebCAT.Rotations.Classrooms do
  @moduledoc """
  Utility functions for working with classrooms
  """
  alias WebCAT.Repo
  alias WebCAT.Rotations.{Rotation, Student}
  alias WebCAT.Accounts.User

  import Ecto.Query

  @doc """
  Get all rotations for a classroom
  """
  @spec rotations(integer, Keyword.t) :: [Rotation.t]
  def rotations(classroom_id, options \\ []) do
    Rotation
    |> where([r], r.classroom_id == ^classroom_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Get all students for a classroom
  """
  @spec students(integer, Keyword.t) :: [Student.t]
  def students(classroom_id, options \\ []) do
    Student
    |> where([s], s.classroom_id == ^classroom_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Get all instructors for a classroom
  """
  @spec instructors(integer, Keyword.t) :: [User.t]
  def instructors(classroom_id, options \\ []) do
    User
    |> join(:inner, [u], uc in "user_classrooms", uc.user_id == u.id)
    |> where([_, uc], uc.classroom_id == ^classroom_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by([c, _], desc: c.inserted_at)
    |> select([c, _], c)
    |> Repo.all()
  end
end
