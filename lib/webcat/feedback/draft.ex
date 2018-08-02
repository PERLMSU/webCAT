defmodule WebCAT.Feedback.Draft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drafts" do
    field(:content, :string)
    field(:status, :string)

    belongs_to(:instructor, WebCAT.Feedback.User)
    belongs_to(:student, WebCAT.Rotations.Student)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    timestamps()
  end

  @doc """
  Create a changeset for a draft
  """
  def changeset(draft, attrs \\ %{}) do
    draft
    |> cast(attrs, ~w(content status instructor_id student_id rotation_group_id)a)
    |> validate_required(~w(content status instructor_id student_id rotation_group_id)a)
    |> validate_inclusion(:status, ~w(review needs_revision approved emailed))
    |> foreign_key_constraint(:instructor_id)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:rotation_group_id)
  end
end
