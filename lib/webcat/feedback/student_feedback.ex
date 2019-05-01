defmodule WebCAT.Feedback.StudentFeedback do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Feedback.{Feedback, Observation}
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.RotationGroup
  alias __MODULE__

  @primary_key false
  schema "student_feedback" do
    belongs_to(:user, User, primary_key: true)
    belongs_to(:rotation_group, RotationGroup, primary_key: true)
    belongs_to(:feedback, Feedback, primary_key: true)

    timestamps(type: :utc_datetime)
  end

  @required ~w(feedback_id user_id rotation_group_id)a
  def changeset(student_feedback, attrs \\ %{}) do
    student_feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:feedback_id)
    |> foreign_key_constraint(:rotation_group_id)
  end

  @doc """
  List all feedback items for a student in a particular rotation group, and group them by observation
  """
  def by_observation(rotation_group_id, user_id) do
    Observation
    |> join(:left, [o], f in assoc(o, :feedback))
    |> join(:left, [o], c in assoc(o, :category))
    |> join(:left, [_, f], sf in StudentFeedback, on: sf.feedback_id == f.id)
    |> where([_, _, _, sf], sf.rotation_group_id == ^rotation_group_id)
    |> where([_, _, _, sf], sf.user_id == ^user_id)
    |> preload([_, f, c], feedback: f, category: c)
    |> Repo.all()
  end

  @doc """
  Add a feedback item to a student in a rotation group
  """
  def add(rotation_group_id, user_id, feedback_id) do
    %StudentFeedback{}
    |> changeset(%{
      rotation_group_id: rotation_group_id,
      user_id: user_id,
      feedback_id: feedback_id
    })
    |> Repo.insert(on_conflict: :nothing)
  end
end
