defmodule WebCAT.Feedback.Observation do
  @behaviour Bodyguard.Policy
  
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "observations" do
    field(:content, :string)
    field(:type, :string)

    belongs_to(:category, WebCAT.Feedback.Category)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    has_many(:notes, WebCAT.Feedback.Note)
    has_many(:explanations, WebCAT.Feedback.Explanation)

    timestamps()
  end

  @doc """
  Create a changeset for an observation
  """
  def changeset(observation, attrs \\ %{}) do
    observation
    |> cast(attrs, ~w(content type category_id rotation_group_id)a)
    |> validate_required(~w(content type category_id rotation_group_id)a)
    |> validate_inclusion(:type, ~w(positive neutral negative))
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:rotation_group_id)
  end

  def title_for(observation) do
    observation.content
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
