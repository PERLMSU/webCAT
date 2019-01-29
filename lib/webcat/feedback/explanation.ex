defmodule WebCAT.Feedback.Explanation do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "explanations" do
    field(:content, :string)

    belongs_to(:observation, WebCAT.Feedback.Observation)

    timestamps()
  end

  @required ~w(content observation_id)a
  @optional ~w()a

  @doc """
  Create a changeset for an explanation
  """
  def changeset(explanation, attrs \\ %{}) do
    explanation
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:observation_id)
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
