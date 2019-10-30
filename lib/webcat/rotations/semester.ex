defmodule WebCAT.Rotations.Semester do
  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.Section
  import WebCAT.Repo.Utils

  schema "semesters" do
    field(:name, :string)
    field(:description, :string)
    field(:start_date, :date)
    field(:end_date, :date)

    has_many(:sections, Section)
    many_to_many(:users, User, join_through: "semester_users", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name start_date end_date)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a semester
  """
  def changeset(semester, attrs \\ %{}) do
    semester
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_dates_after(:start_date, :end_date)
    |> put_relation(:users, User, Map.get(attrs, "users", []))
 end
end
