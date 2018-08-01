defmodule WebCAT.Feedback.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field(:content, :string)

    belongs_to(:student, WebCAT.Rotations.Student)
    belongs_to(:observation, WebCAT.Feedback.Observation)

    timestamps()
  end

  def changeset(note, attrs \\ %{}) do
    note
    |> cast(attrs, ~w(content student_id observation_id)a)
    |> validate_required(~w(content student_id)a)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:observation_id)
  end
end
