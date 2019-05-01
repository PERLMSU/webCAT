defmodule WebCATWeb.ObservationView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.{Category, Observation}

  def render("list.json", %{observations: observations}) do
    render_many(observations, __MODULE__, "observation.json")
  end

  def render("show.json", %{observation: observation}) do
    render_one(observation, __MODULE__, "observation.json")
  end

  def render("observation.json", %{observation: %Observation{} = observation}) do
    observation
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{category: %Category{} = category} = map ->
        Map.put(
          map,
          :category,
          render_one(category, WebCATWeb.CategoryView, "category.json")
        )

      map ->
        Map.delete(map, :category)
    end
    |> case do
      %{feedback: feedback} = map when is_list(feedback) ->
        Map.put(map, :feedback, render_many(feedback, WebCATWeb.FeedbackView, "feedback.json"))

      map ->
        Map.delete(map, :feedback)
    end
  end
end
