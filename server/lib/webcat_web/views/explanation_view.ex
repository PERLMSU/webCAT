defmodule WebCATWeb.ExplanationView do
  @moduledoc """
  Render explanations
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Explanation

  def render("list.json", %{explanations: explanations}) do
    render_many(explanations, __MODULE__, "explanation.json")
  end

  def render("show.json", %{explanation: explanation}) do
    render_one(explanation, __MODULE__, "explanation.json")
  end

  def render("explanation.json", %{explanation: %Explanation{} = explanation}) do
    explanation
    |> Map.from_struct()
    |> Map.take(~w(id content feedback_id inserted_at updated_at)a)
  end
end
