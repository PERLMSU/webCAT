defmodule WebCAT.Accounts.Notification do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "notifications" do
    field(:content, :string)
    field(:seen, :boolean, default: false)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:user, User)

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

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list)a,
      do: true

  def authorize(action, %User{id: id}, %__MODULE__{user_id: id})
      when action in ~w(show)a,
      do: true

  def authorize(_, _, _), do: false
end
