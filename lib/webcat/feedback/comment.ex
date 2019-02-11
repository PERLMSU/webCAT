defmodule WebCAT.Feedback.Comment do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Groups}

  schema "comments" do
    field(:content, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)
    belongs_to(:user, User)

    timestamps()
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

  # Policy behaviour
  def authorize(action, %User{}, _)
      when action in ~w(list show create)a,
      do: true

  def authorize(action, %User{id: id}, %__MODULE__{user_id: id})
      when action in ~w(update delete)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
