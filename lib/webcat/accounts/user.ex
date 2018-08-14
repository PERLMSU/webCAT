defmodule WebCAT.Accounts.User do
  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  alias Comeonin.Pbkdf2
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
    field(:role, :string)

    has_many(:rotation_groups, WebCAT.Rotations.RotationGroup, foreign_key: :instructor_id)
    has_many(:notifications, WebCAT.Accounts.Notification)
    many_to_many(:classrooms, WebCAT.Rotations.Classroom, join_through: "user_classrooms")

    timestamps()
  end

  @required ~w(first_name last_name email username password inserted_at updated_at role)a
  @optional ~w(middle_name nickname bio phone city state country active)a

  @doc """
  Build a changeset for a user
  """
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_format(:email, ~r/(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)/)
    # 999-999-9999 format numbers for simplicity
    |> validate_format(:phone, ~r/^\d{3}-\d{3}-\d{4}$/)
    # MI, AZ, AK, etc.
    |> validate_format(:state, ~r/^[A-Z]{2}$/)
    # letters and numbers up to 24 characters
    |> validate_format(:username, ~r/^[\w\d]{1,24}$/)
    |> validate_inclusion(:role, ~w(instructor admin))
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  @doc """
  Build a changeset for creating a user
  """
  def create_changeset(user, attrs \\ %{}) do
    changeset(user, attrs)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Pbkdf2.hashpwsalt(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
