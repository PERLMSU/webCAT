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

  @doc """
  Create a changeset for an explanation
  """
  def changeset(explanation, attrs \\ %{}) do
    explanation
    |> cast(attrs, ~w(content observation_id)a)
    |> validate_required(~w(content observation_id)a)
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
