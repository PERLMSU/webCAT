defmodule WebCAT.Rotations.Student do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "students" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:description, :string)
    field(:email, :string)

    many_to_many(:rotation_groups, WebCAT.Rotations.RotationGroup, join_through: "student_groups")
    many_to_many(:sections, WebCAT.Rotations.Section, join_through: "student_sections")
    has_many(:notes, WebCAT.Feedback.Note)

    timestamps()
  end

  @required ~w(first_name last_name)a
  @optional ~w(middle_name description email)a

  @doc """
  Build a changeset for a student
  """
  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:classroom_id)
    |> unique_constraint(:email)
  end


  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create update delete)a,
      do: true

  def authorize(_, _, _), do: false
end
