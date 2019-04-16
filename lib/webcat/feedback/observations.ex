defmodule WebCAT.Feedback.Observations do
  import Ecto.Query
  alias WebCAT.Feedback.Observation
  alias WebCAT.Rotations.Classroom
  alias WebCAT.Repo

  def list(category_id) do
    from(observation in Observation,
      where: observation.category_id == ^category_id,
      left_join: category in assoc(observation, :category),
      left_join: classroom in assoc(category, :classroom),
      preload: [category: {category, classroom: classroom}]
    )
    |> Repo.all()
  end

  def get(id) when is_binary(id) or is_integer(id) do
    from(observation in Observation,
      where: observation.id == ^id,
      left_join: category in assoc(observation, :category),
      left_join: classroom in assoc(category, :classroom),
      left_join: feedback in assoc(observation, :feedback),
      preload: [feedback: feedback, category: {category, classroom: classroom}]
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      observation ->
        {:ok, observation}
    end
  end

  def observations_per_student(%Classroom{id: classroom_id}) do
    


    [["Mar 6", 2.2], ["Mar 13", 4.5], ["Mar 20", 3.4], ["Mar 27", 5.5]]
  end
end
