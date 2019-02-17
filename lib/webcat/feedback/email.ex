defmodule WebCAT.Feedback.Email do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Groups}

  schema "emails" do
    field(:status, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)

    timestamps()
  end

  @required ~w(status draft_id)a

  @doc """
  Create a changeset for an email
  """
  def changeset(email, attrs \\ %{}) do
    email
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:draft_id)
  end
end
