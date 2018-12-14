defmodule WebCAT.Feedback.Note do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "notes" do
    field(:content, :string)

    belongs_to(:student, WebCAT.Rotations.Student)
    belongs_to(:observation, WebCAT.Feedback.Observation)

    timestamps()
  end

  @doc """
  Create a changeset for a note
  """
  def changeset(note, attrs \\ %{}) do
    note
    |> cast(attrs, ~w(content student_id observation_id)a)
    |> validate_required(~w(content)a)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:observation_id)
  end

  def title_for(note) do
    String.slice(note.content, 0..15) <> "..."
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
