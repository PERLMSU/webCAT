defmodule WebCAT.Rotations.RotationGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User
  import WebCAT.Repo.Utils

  schema "rotation_groups" do
    field(:number, :integer)
    field(:description, :string)

    belongs_to(:rotation, WebCAT.Rotations.Rotation)

    many_to_many(:users, User,
      join_through: "rotation_group_users",
      on_replace: :delete
    )

    has_one(:classroom, through: ~w(rotation section classroom)a)

    timestamps(type: :utc_datetime)
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
    |> put_relation(:users, User, Map.get(attrs, "users", []))
  end
end
