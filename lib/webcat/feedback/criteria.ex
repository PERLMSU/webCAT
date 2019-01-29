defmodule WebCAT.Feedback.Criteria do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "criteria" do
    field(:min, :integer)
    field(:max, :integer)
    field(:title, :string)
    field(:description, :string)

    belongs_to(:classroom, WebCAT.Rotations.Classroom)

    timestamps()
  end

  @required ~w(min max title description classroom_id)a
  @optional ~w()a

  @doc """
  Create a changeset for a criteria
  """
  def changeset(criteria, attrs \\ %{}) do
    criteria
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:classroom_id)
    |> unique_constraint(:title)
  end

  # Policy behaviour
  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create update delete)a,
      do: true

  def authorize(_, _, _), do: false
end
