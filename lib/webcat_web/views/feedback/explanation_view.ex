defmodule WebCATWeb.ExplanationView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.{Feedback, Explanation}

  def render("list.json", %{explanations: explanations}) do
    render_many(explanations, __MODULE__, "explanation.json")
  end

  def render("show.json", %{explanation: explanation}) do
    render_one(explanation, __MODULE__, "explanation.json")
  end

  def render("explanation.json", %{explanation: %Explanation{} = explanation}) do
    explanation
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{feedback: %Feedback{} = feedback} = map ->
        Map.put(
          map,
          :feedback,
          render_one(feedback, WebCATWeb.FeedbackView, "feedback.json")
        )

      map ->
        Map.delete(map, :feedback)
    end
  end
end
