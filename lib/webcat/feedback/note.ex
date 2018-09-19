defmodule WebCAT.Feedback.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field(:content, :string)

    belongs_to(:student, WebCAT.Rotations.Student)
    belongs_to(:observation, WebCAT.Feedback.Observation)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    timestamps()
  end

  @doc """
  Create a changeset for a note
  """
  def changeset(note, attrs \\ %{}) do
    note
    |> cast(attrs, ~w(content student_id observation_id rotation_group_id)a)
    |> validate_required(~w(content)a)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:observation_id)
    |> foreign_key_constraint(:rotation_group_id)
  end
end
