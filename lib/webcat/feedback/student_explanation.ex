defmodule WebCAT.Feedback.StudentExplanation do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Feedback.{Feedback, Explanation}
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.RotationGroup
  alias __MODULE__

  @primary_key false
  schema "student_explanations" do
    belongs_to(:student, User, primary_key: true)
    belongs_to(:rotation_group, RotationGroup, primary_key: true)
    belongs_to(:feedback, Feedback, primary_key: true)
    belongs_to(:explanation, Explanation, primary_key: true)

    timestamps(type: :utc_datetime)
  end

  @required ~w(feedback_id student_id rotation_group_id explanation_id)a
  def changeset(student_feedback, attrs \\ %{}) do
    student_feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:rotation_group_id)
    |> foreign_key_constraint(:feedback_id)
    |> foreign_key_constraint(:eplanation_id)
  end

  @doc """
  Add a feedback item to a student in a rotation group
  """
  def add(rotation_group_id, student_id, feedback_id, explanation_id) do
    %StudentExplanation{}
    |> changeset(%{
      rotation_group_id: rotation_group_id,
      student_id: student_id,
      feedback_id: feedback_id,
      explanation_id: explanation_id
    })
    |> Repo.insert(on_conflict: :nothing)
  end

  def delete(rotation_group_id, student_id, feedback_id, explanation_id) do
    from(se in StudentExplanation,
      where: se.rotation_group_id == ^rotation_group_id,
      where: se.student_id == ^student_id,
      where: se.feedback_id == ^feedback_id,
      where: se.explanation_id == ^explanation_id
    )
    |> Repo.delete_all()

    :ok
  end
end
