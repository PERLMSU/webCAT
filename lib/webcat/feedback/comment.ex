defmodule WebCAT.Feedback.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field(:content, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:user, WebCAT.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  @required ~w(content draft_id user_id)a
  @optional ~w()a

  @doc """
  Create a changeset for a comment
  """
  def changeset(comment, attrs \\ %{}) do
    comment
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:draft_id)
    |> foreign_key_constraint(:user_id)
  end
end
