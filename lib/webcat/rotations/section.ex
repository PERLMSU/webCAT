defmodule WebCAT.Rotations.Section do
  @behaviour WebCAT.Dashboardable
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "sections" do
    field(:number, :string)
    field(:description, :string)

    belongs_to(:semester, WebCAT.Rotations.Semester)
    has_many(:rotations, WebCAT.Rotations.Rotation)
    many_to_many(:users, WebCAT.Accounts.User, join_through: "user_sections")
    many_to_many(:students, WebCAT.Rotations.Student, join_through: "section_students")

    timestamps()
  end


  @required ~w(number semester_id)a
  @optional ~w(description)a
  def changeset(section, attrs \\ %{}) do
    section
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:semester_id)
  end

  # Policy behaviour

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create update delete)a,
      do: true

  @spec authorize(any(), any(), any()) :: false
  def authorize(_, _, _), do: false
end
