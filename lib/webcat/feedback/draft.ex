defmodule WebCAT.Feedback.Draft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drafts" do
    field(:content, :string)
    field(:status, :string, default: "unreviewed")

    belongs_to(:user, WebCAT.Accounts.User)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    has_many(:comments, WebCAT.Feedback.Comment)
    has_many(:grades, WebCAT.Feedback.Grade)

    timestamps(type: :utc_datetime)
  end

  @required ~w(content status user_id rotation_group_id)a

  @doc """
  Create a changeset for a draft
  """
  def changeset(draft, attrs \\ %{}) do
    draft
    |> cast(attrs, @required)
    |> cast_assoc(:grades)
    |> validate_required(@required)
    |> validate_inclusion(:status, ~w(unreviewed reviewing needs_revision approved emailed))
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:rotation_group_id)
  end
end
