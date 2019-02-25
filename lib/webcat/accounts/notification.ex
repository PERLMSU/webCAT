defmodule WebCAT.Accounts.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field(:content, :string)
    field(:seen, :boolean, default: false)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  @required ~w(content draft_id user_id)a
  @optional ~w(seen)a

  @doc """
  Create a changeset for a notification
  """
  def changeset(notification, attrs \\ %{}) do
    notification
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:draft_id)
    |> foreign_key_constraint(:user_id)
  end
end
