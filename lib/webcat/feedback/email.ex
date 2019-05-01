defmodule WebCAT.Feedback.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field(:status, :string)

    belongs_to(:draft, WebCAT.Feedback.Draft)

    timestamps(type: :utc_datetime)
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
