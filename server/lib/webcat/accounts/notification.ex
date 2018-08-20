defmodule WebCAT.Accounts.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field(:content, :string)
    field(:seen, :boolean)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  @doc """
  Create a changeset for a grade
  """
  def changeset(grade, attrs \\ %{}) do
    grade
    |> cast(attrs, ~w(content seen draft_id user_id)a)
    |> validate_required(~w(content draft_id user_id)a)
    |> foreign_key_constraint(:draft_id)
    |> foreign_key_constraint(:user_id)
  end
end
