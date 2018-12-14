defmodule WebCAT.Accounts.Notification do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "notifications" do
    field(:content, :string)
    field(:seen, :boolean)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  @required ~w(content draft_id user_id)a
  @optional ~w(seen)a

  @doc """
  Create a changeset for a grade
  """
  def changeset(grade, attrs \\ %{}) do
    grade
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:draft_id)
    |> foreign_key_constraint(:user_id)
  end

  def title_for(notification) do
    String.slice(notification.content, 0..15) <> "..."
  end

  # Policy behavior

  def authorize(action, %User{id: id}, %__MODULE__{user_id: id})
      when action in ~w(list show)a,
      do: true

  def authorize(_, _, _), do: false
end
