defmodule WebCAT.Accounts.User do
  @behaviour WebCAT.Dashboardable
  @behaviour Bodyguard.Policy

  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  alias Comeonin.Pbkdf2
  import Ecto.Changeset
  alias WebCAT.Accounts.User

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

  @required ~w(first_name last_name email username password role)a
  @optional ~w(middle_name nickname bio phone city state country birthday active)a

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

  def title_for(user), do: "#{user.first_name} #{user.last_name}"

  def table_fields(), do: ~w(last_name first_name username email role)a

  def display(user) do
    user
    |> Map.from_struct()
    |> Map.take(@required ++ @optional)
    |> Map.drop(~w(password)a)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list_users show_user)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_user update_user delete_user)a,
      do: true

  def authorize(action, %User{role: "admin"}, %User{role: "instructor"})
      when action in ~w(update_user delete_user)a,
      do: true

  def authorize(action, %User{role: "admin"}, %User{role: "instructor"})
      when action in ~w(list_notifications list_classrooms list_rotation_groups)a,
      do: true

  def authorize(action, %User{id: id}, %User{id: id})
      when action in ~w(update_user list_notifications list_classrooms list_rotation_groups)a,
      do: true

  def authorize(_, _, _), do: false
end
