defmodule WebCAT.Feedback.Draft do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Group, Groups}

  schema "drafts" do
    field(:content, :string)
    field(:status, :string)

    belongs_to(:student, WebCAT.Rotations.Student)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    has_many(:comments, WebCAT.Feedback.Comment)
    has_many(:grades, WebCAT.Feedback.Grade)

    timestamps()
  end

  @required ~w(content status student_id rotation_group_id)a

  @doc """
  Create a changeset for a draft
  """
  def changeset(draft, attrs \\ %{}) do
    draft
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_inclusion(:status, ~w(unreviewed reviewing needs_revision approved emailed))
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:rotation_group_id)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{}, _)
      when action in ~w(create update)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(send delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
