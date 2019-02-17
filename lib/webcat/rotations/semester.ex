defmodule WebCAT.Rotations.Semester do
  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators
  import Ecto.Query
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "semesters" do
    field(:name, :string)
    field(:start_date, :date)
    field(:end_date, :date)

    belongs_to(:classroom, WebCAT.Rotations.Classroom)
    has_many(:sections, WebCAT.Rotations.Section)
    many_to_many(:users, User, join_through: "semester_users")

    timestamps()
  end

  @required ~w(name start_date end_date classroom_id)a

  @doc """
  Build a changeset for a semester
  """
  def changeset(semester, attrs \\ %{}) do
    semester
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:classroom_id)
    |> put_users(Map.get(attrs, "users"))
  end

  defp put_users(%{valid?: true} = changeset, users) when is_list(users) do
    put_assoc(changeset, :users, Repo.all(from(u in User, where: u.id in ^users)))
  end

  defp put_users(changeset, _), do: changeset
end
