defmodule WebCAT.Feedback.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grades" do
    field(:score, :integer)
    field(:note, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:category, WebCAT.Feedback.Category)

    timestamps(type: :utc_datetime)
  end

  @required ~w(score category_id)a
  @optional ~w(draft_id note)a

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
