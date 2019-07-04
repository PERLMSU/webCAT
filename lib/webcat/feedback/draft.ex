defmodule WebCAT.Feedback.Draft do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Accounts.User

  schema "drafts" do
    field(:content, :string)
    field(:status, :string, default: "unreviewed")

    many_to_many(:authors, User, join_through: "draft_authors", on_replace: :delete)
    belongs_to(:reviewer, User)
    belongs_to(:student, User)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    has_many(:comments, WebCAT.Feedback.Comment)
    has_many(:grades, WebCAT.Feedback.Grade)

    timestamps(type: :utc_datetime)
  end

  @required ~w(content status student_id rotation_group_id)a
  @optional ~w(reviewer_id)a

  @doc """
  Create a changeset for a draft
  """
  def changeset(draft, attrs \\ %{}) do
    draft
    |> cast(attrs, @required ++ @optional)
    |> cast_assoc(:grades)
    |> validate_required(@required)
    |> validate_inclusion(:status, ~w(unreviewed reviewing needs_revision approved emailed))
    |> foreign_key_constraint(:reviewer_id)
    |> foreign_key_constraint(:student_id, name: "drafts_student_group_fkey")
    |> foreign_key_constraint(:rotation_group_id, name: "drafts_student_group_fkey")
    |> put_authors(Map.get(attrs, "authors"))
  end

  defp put_authors(%{valid?: true} = changeset, users) when is_list(users) do
    ids =
      users
      |> Enum.map(fn user ->
        case user do
          %{id: id} ->
            id

          id when is_integer(id) ->
            id

          id when is_binary(id) ->
            String.to_integer(id)

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    # This is being forced because we know if a list of ids are being passed, we want to overwrite.
    # This is not the recommended behavior of changesets, be warned, but it's a huge inconvenience to preload something
    # we know is just going to be trashed in the same transaction.
    changeset
    |> Map.put(:data, Map.put(changeset.data, :authors, []))
    |> put_assoc(:authors, Repo.all(from(u in User, where: u.id in ^ids)))
  end

  defp put_authors(changeset, _), do: changeset
end
