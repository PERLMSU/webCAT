defmodule WebCAT.Feedback.StudentExplanation do
  use Ecto.Schema
  import Ecto.Changeset

  alias WebCAT.Feedback.{Feedback, Explanation, Draft}

  @primary_key false
  schema "student_explanations" do
    field(:id, :integer, auto_generate: true)

    belongs_to(:draft, Draft, primary_key: true)
    belongs_to(:feedback, Feedback, primary_key: true)
    belongs_to(:explanation, Explanation, primary_key: true)

    has_one(:observation, through: ~w(feedback observation)a)
    has_one(:category, through: ~w(feedback observation category)a)

    timestamps(type: :utc_datetime)
  end

  @required ~w(feedback_id draft_id explanation_id)a
  def changeset(student_feedback, attrs \\ %{}) do
    student_feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:rotation_group_id)
    |> foreign_key_constraint(:feedback_id)
    |> foreign_key_constraint(:explanation_id)
  end
end
