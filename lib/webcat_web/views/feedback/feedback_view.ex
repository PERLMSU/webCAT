defmodule WebCATWeb.FeedbackView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.{Feedback, Observation}

  def render("list.json", %{feedback: feedback}) do
    render_many(feedback, __MODULE__, "feedback.json")
  end

  def render("show.json", %{feedback: feedback}) do
    render_one(feedback, __MODULE__, "feedback.json")
  end

  def render("feedback.json", %{feedback: %Feedback{} = feedback}) do
    feedback
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{observation: %Observation{} = observation} = map ->
        Map.put(
          map,
          :observation,
          render_one(observation, WebCATWeb.ObservationView, "observation.json")
        )

      map ->
        Map.delete(map, :observation)
    end
  end
end
