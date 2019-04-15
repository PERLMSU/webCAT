defmodule WebCAT.Rotations.Rotation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import WebCAT.Validators
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "rotations" do
    field(:number, :integer)
    field(:description, :string)
    field(:end_date, :date)
    field(:start_date, :date)

    belongs_to(:section, WebCAT.Rotations.Section)
    has_many(:rotation_groups, WebCAT.Rotations.RotationGroup)
    many_to_many(:users, User, join_through: "rotation_users", on_replace: :delete)

    timestamps()
  end

  @required ~w(number start_date end_date section_id)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a rotation
  """
  def changeset(rotation, attrs \\ %{}) do
    rotation
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:section_id)
    |> put_users(Map.get(attrs, "users"))
  end

  defp put_users(%{valid?: true} = changeset, users) when is_list(users) do
    ids =
      users
      |> Enum.map(fn user ->
        case user do
          %{id: id} ->
            id

          id when is_integer(id) ->
            id

          id when is_binary(id) ->
            String.to_integer(id)

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    put_assoc(changeset, :users, Repo.all(from(u in User, where: u.id in ^ids)))
  end

  defp put_users(changeset, _), do: changeset
end
