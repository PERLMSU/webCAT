defmodule WebCATWeb.ObservationView do
  @moduledoc """
  Render observations
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Observation

  def render("list.json", %{observations: observations}) do
    render_many(observations, __MODULE__, "observation.json")
  end

  def render("show.json", %{observation: observation}) do
    render_one(observation, __MODULE__, "observation.json")
  end

  def render("observation.json", %{observation: %Observation{} = observation}) do
    observation
    |> Map.from_struct()
    |> Map.take(~w(id content type category_id rotation_group_id inserted_at updated_at)a)
  end
end
