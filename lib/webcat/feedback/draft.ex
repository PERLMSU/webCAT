defmodule WebCAT.Feedback.Draft do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "drafts" do
    field(:content, :string)
    field(:status, :string)
    field(:score, :float)

    belongs_to(:student, WebCAT.Rotations.Student)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    many_to_many(:observations, WebCAT.Feedback.Observation, join_through: "draft_observations")

    timestamps()
  end

  @doc """
  Create a changeset for a draft
  """
  def changeset(draft, attrs \\ %{}) do
    draft
    |> cast(attrs, ~w(content status score student_id rotation_group_id)a)
    |> validate_required(~w(content status score student_id rotation_group_id)a)
    |> validate_inclusion(:status, ~w(unreviewed review needs_revision approved emailed))
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:rotation_group_id)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list_drafts show_draft)a,
      do: true

  def authorize(action, %User{}, _)
      when action in ~w(create_draft update_draft)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(send_draft delete_draft)a,
      do: true

  def authorize(_, _, _), do: false
end
