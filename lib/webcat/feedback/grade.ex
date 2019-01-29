defmodule WebCAT.Feedback.Grade do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "grades" do
    field(:score, :integer)
    field(:note, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:criteria, WebCAT.Feedback.Criteria)

    timestamps()
  end

  @required ~w(score draft_id criteria_id)a
  @optional ~w(note)a

  @doc """
  Create a changeset for a grade
  """
  def changeset(grade, attrs \\ %{}) do
    grade
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:draft_id)
    |> foreign_key_constraint(:criteria_id)
  end

  # Policy behaviour
  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{}, _)
      when action in ~w(create update delete)a,
      do: true

  def authorize(_, _, _), do: false
end
