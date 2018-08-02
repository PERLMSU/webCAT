defmodule WebCAT.Feedback.Email do
  use Ecto.Schema
  import Ecto.Changeset

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
end
