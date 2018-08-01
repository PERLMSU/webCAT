defmodule WebCAT.Accounts.User do
  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:email, :string)
    field(:username, :string)
    field(:password, :string)
    field(:nickname, :string)
    field(:bio, :string)
    field(:phone, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)
    field(:birthday, :date)
    field(:active, :boolean)

    has_many(:rotation_groups, WebCAT.Rotations.RotationGroup)
    has_many(:drafts, WebCAT.Feedback.Draft)
    has_many(:notifications, WebCAT.Feedback.Notification)
    many_to_many(:role_groups, WebCAT.Accounts.RoleGroup, join_through: "role_group_users")

    timestamps()
  end

  @required ~w(first_name last_name email username password active inserted_at updated_at)a
  @optional ~w(middle_name nickname bio phone city state country)a

  @doc """
  Build a changeset for a user
  """
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end
end
