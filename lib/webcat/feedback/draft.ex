defmodule WebCAT.Feedback.Draft do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Accounts.User

  schema "drafts" do
    field(:content, :string)
    field(:status, :string, default: "unreviewed")
    field(:notes, :string)

    belongs_to(:parent_draft, __MODULE__)
    belongs_to(:student, User)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    has_many(:comments, WebCAT.Feedback.Comment)
    has_many(:grades, WebCAT.Feedback.Grade)
    has_many(:child_drafts, __MODULE__, foreign_key: :parent_draft_id)

    # Relationships based on joins
    has_one(:classroom, through: ~w(rotation_group rotation section classroom)a)
    has_many(:group_categories, through: ~w(rotation_group rotation section classroom categories)a)
    has_many(:student_categories, through: ~w(parent_draft rotation_group rotation section classroom categories)a)
    has_many(:group_users, through: ~w(rotation_group users)a)

    timestamps(type: :utc_datetime)
  end

  @required ~w(content status)a
  @optional ~w(notes student_id rotation_group_id parent_draft_id)a

  @doc """
  Create a changeset for a draft
  """
  def changeset(draft, attrs \\ %{}) do
    draft
    |> cast(attrs, @required ++ @optional)
    |> cast_assoc(:grades)
    |> validate_required(@required)
    |> validate_inclusion(:status, ~w(unreviewed reviewing needs_revision approved emailed))
    |> foreign_key_constraint(:student_id, name: "drafts_student_group_fkey")
    |> foreign_key_constraint(:rotation_group_id, name: "drafts_student_group_fkey")
    |> check_draft_type()
  end

  defp check_draft_type(%{valid?: true} = changeset) do
    has_parent_draft = not is_nil(get_field(changeset, :parent_draft_id))
    has_student = not is_nil(get_field(changeset, :student_id))
    has_group = not is_nil(get_field(changeset, :rotation_group_id))

    cond do
      has_parent_draft and has_group -> add_error(changeset, :rotation_group_id, "must be blank when draft has a parent")
      has_parent_draft and not has_student -> add_error(changeset, :student_id, "cannot be blank when draft has a parent")
      not has_parent_draft and not has_group -> add_error(changeset, :rotation_group_id, "cannot be blank when the draft is top-level")
      not has_parent_draft and has_student -> add_error(changeset, :student_id, "must be blank when top-level draft")
      true -> changeset
    end
  end

  defp check_draft_type(changeset), do: changeset
end
