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

    many_to_many(:students, WebCAT.Rotations.Student, join_through: "student_groups")
    many_to_many(:users, WebCAT.Accounts.User, join_through: "rotation_group_users")
    has_many(:observations, WebCAT.Feedback.Observation)

    timestamps()
  end

  @required ~w(number rotation_id)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a rotation group
  """
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:rotation_id)
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
