defmodule WebCAT.Accounts.RoleGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "role_groups" do
    field(:name, :string)

    many_to_many(:users, WebCAT.Accounts.User, join_through: "role_group_users")

    timestamps()
  end

  @doc """
  Build a changeset for a role group
  """
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, ~w(name)a)
    |> validate_required(~w(name)a)
    |> unique_constraint(:token)
  end
end
