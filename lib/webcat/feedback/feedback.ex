defmodule WebCAT.Feedback.Feedback do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Repo

  schema "feedback" do
    field(:content, :string)

    belongs_to(:observation, WebCAT.Feedback.Observation)

    timestamps(type: :utc_datetime)
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

  def list(observation_id) do
    from(feedback in __MODULE__,
      where: feedback.observation_id == ^observation_id
    )
    |> Repo.all()
  end

  def get(id) when is_binary(id) or is_integer(id) do
    from(feedback in __MODULE__,
      where: feedback.id == ^id,
      left_join: observation in assoc(feedback, :observation),
      left_join: category in assoc(observation, :category),
      left_join: classroom in assoc(category, :classroom),
      preload: [observation: {observation, category: {category, classroom: classroom}}]
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      feedback ->
        {:ok, feedback}
    end
  end
end
