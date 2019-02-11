defmodule WebCAT.Accounts.Group do
  @behaviour Bodyguard.Policy

  @moduledoc """
  Allows grouping of users for access control
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Groups}

  schema "groups" do
    field(:name, :string)

    timestamps()
  end

  @required ~w(name)a

  @doc """
  Build a changeset for a group
  """
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:name)
  end

  # Policy behavior
  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
