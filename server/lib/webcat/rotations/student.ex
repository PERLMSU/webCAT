defmodule WebCAT.Rotations.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:description, :string)
    field(:email, :string)

    belongs_to(:classroom, WebCAT.Rotations.Classroom)
    has_many(:notes, WebCAT.Feedback.Note)
    has_many(:drafts, WebCAT.Feedback.Draft)
    many_to_many(:rotation_groups, WebCAT.Rotations.RotationGroup, join_through: "student_groups")

    timestamps()
  end

  @doc """
  Build a changeset for a student
  """
  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, ~w(first_name last_name middle_name description email classroom_id)a)
    |> validate_required(~w(first_name last_name classroom_id)a)
    |> foreign_key_constraint(:classroom_id)
    |> unique_constraint(:email)
  end
end
