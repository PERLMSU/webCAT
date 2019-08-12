defmodule WebCAT.Feedback.StudentFeedback do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Feedback.{Feedback, Observation, Category, StudentExplanation}
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.RotationGroup
  alias __MODULE__

  @primary_key false
  schema "student_feedback" do
    belongs_to(:student, User, primary_key: true)
    belongs_to(:rotation_group, RotationGroup, primary_key: true)
    belongs_to(:feedback, Feedback, primary_key: true)

    timestamps(type: :utc_datetime)
  end

  @required ~w(feedback_id student_id rotation_group_id)a
  def changeset(student_feedback, attrs \\ %{}) do
    student_feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:feedback_id)
    |> foreign_key_constraint(:rotation_group_id)
  end

  @doc """
  List all feedback items for a student in a particular rotation group, and group them by observation
  """
  def by_observation(rotation_group_id, student_id) do
    Observation
    |> join(:left, [o], f in assoc(o, :feedback))
    |> join(:left, [o], c in assoc(o, :category))
    |> join(:left, [_, f], sf in StudentFeedback, on: sf.feedback_id == f.id)
    |> where([_, _, _, sf], sf.rotation_group_id == ^rotation_group_id)
    |> where([_, _, _, sf], sf.student_id == ^student_id)
    |> preload([_, f, c], feedback: f, category: c)
    |> Repo.all()
  end

  def by_category(rotation_group_id, student_id) do
    from(c in Category,
      left_join: o in assoc(c, :observations),
      left_join: f in assoc(o, :feedback),
      left_join: e in assoc(f, :explanations),
      left_join: sf in StudentFeedback, on: sf.feedback_id == f.id,
      where: sf.rotation_group_id == ^rotation_group_id,
      where: sf.student_id == ^student_id,
      preload: [observations: {o, feedback: {f, explanations: e}}]
    )
    |> Repo.all()
  end

  @doc """
  Add a feedback item to a student in a rotation group
  """
  def add(rotation_group_id, student_id, feedback_id) do
    %StudentFeedback{}
    |> changeset(%{
      rotation_group_id: rotation_group_id,
      student_id: student_id,
      feedback_id: feedback_id
    })
    |> Repo.insert(on_conflict: :nothing)
  end

  def delete(rotation_group_id, student_id, feedback_id) do
    from(sf in StudentFeedback,
      where: sf.rotation_group_id == ^rotation_group_id,
      where: sf.student_id == ^student_id,
      where: sf.feedback_id == ^feedback_id
    )
    |> Repo.delete_all()

    :ok
  end
end
