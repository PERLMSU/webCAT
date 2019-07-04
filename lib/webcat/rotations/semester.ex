defmodule WebCAT.Rotations.Semester do
  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators
  import Ecto.Query
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "semesters" do
    field(:name, :string)
    field(:description, :string)
    field(:start_date, :date)
    field(:end_date, :date)

    belongs_to(:classroom, WebCAT.Rotations.Classroom)
    has_many(:sections, WebCAT.Rotations.Section)
    many_to_many(:users, User, join_through: "semester_users", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name start_date end_date classroom_id)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a semester
  """
  def changeset(semester, attrs \\ %{}) do
    semester
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:classroom_id)
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

    changeset
    |> Map.put(:data, Map.put(changeset.data, :users, []))
    |> put_assoc(changeset, :users, Repo.all(from(u in User, where: u.id in ^ids)))
  end

  defp put_users(changeset, _), do: changeset
end
