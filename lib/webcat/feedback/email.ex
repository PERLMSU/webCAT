defmodule WebCAT.Feedback.Email do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "emails" do
    field(:status, :string)
    field(:status_message, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)

    timestamps()
  end

  @doc """
  Create a changeset for an email
  """
  def changeset(email, attrs \\ %{}) do
    email
    |> cast(attrs, ~w(status status_message draft_id)a)
    |> validate_required(~w(status draft_id)a)
    |> foreign_key_constraint(:draft_id)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{}, _)
      when action in ~w(create update delete)a,
      do: true

  def authorize(_, _, _), do: false
end
