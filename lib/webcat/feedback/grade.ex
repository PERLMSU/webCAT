defmodule WebCAT.Feedback.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grades" do
    field(:score, :float)

    belongs_to(:draft, WebCAT.Feedback.Draft)

    timestamps()
  end

  @doc """
  Create a changeset for a grade
  """
  def changeset(grade, attrs \\ %{}) do
    grade
    |> cast(attrs, ~w(score draft_id)a)
    |> validate_required(~w(score draft_id)a)
    |> foreign_key_constraint(:draft_id)
  end
end
