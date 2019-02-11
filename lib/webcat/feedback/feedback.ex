defmodule WebCAT.Feedback.Feedback do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Groups}

  schema "feedback" do
    field(:content, :string)

    belongs_to(:observation, WebCAT.Feedback.Observation)

    timestamps()
  end

  @required ~w(content observation_id)a

  @doc """
  Create a changeset for an feedback
  """
  def changeset(feedback, attrs \\ %{}) do
    feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:observation_id)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
