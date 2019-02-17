defmodule WebCAT.Feedback.Grade do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "grades" do
    field(:score, :integer)
    field(:note, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:category, WebCAT.Feedback.Category)

    timestamps()
  end

  @required ~w(score draft_id category_id)a
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
end
