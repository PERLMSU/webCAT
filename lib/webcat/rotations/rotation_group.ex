defmodule WebCAT.Rotations.RotationGroup do
  @behaviour WebCAT.Dashboardable
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "rotation_groups" do
    field(:description, :string)
    field(:number, :integer)

    belongs_to(:rotation, WebCAT.Rotations.Rotation)
    belongs_to(:instructor, WebCAT.Accounts.User, foreign_key: :instructor_id)

    has_many(:drafts, WebCAT.Feedback.Draft)

    many_to_many(:students, WebCAT.Rotations.Student, join_through: "student_groups")

    timestamps()
  end

  @doc """
  Build a changeset for a rotation group
  """
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, ~w(description number rotation_id instructor_id)a)
    |> validate_required(~w(number rotation_id instructor_id)a)
    |> foreign_key_constraint(:rotation_id)
    |> foreign_key_constraint(:instructor_id)
  end

  def title_for(rotation_group), do: "Group #{rotation_group.number}"

  def table_fields(), do: ~w(number description)a

  def display(rotation_group) do
    rotation_group
    |> Map.from_struct()
    |> Map.take(~w(description number)a)
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
