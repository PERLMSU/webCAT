defmodule WebCATWeb.FeedbackView do
  @moduledoc """
  Render feedback
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Feedback

  def render("list.json", %{feedback: feedback}) do
    render_many(feedback, __MODULE__, "feedback.json")
  end

  def render("show.json", %{feedback: feedback}) do
    render_one(feedback, __MODULE__, "feedback.json")
  end

  def render("feedback.json", %{feedback: %Feedback{} = feedback}) do
    feedback
    |> Map.from_struct()
    |> Map.take(~w(id content observation_id inserted_at updated_at)a)
  end
end
