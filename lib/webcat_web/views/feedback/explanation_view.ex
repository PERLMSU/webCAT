defmodule WebCATWeb.ExplanationView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "explanation", collection: "explanations"

  alias WebCATWeb.FeedbackView

  def fields, do: ~w(content inserted_at updated_at)a ++ ~w(feedback_id)a

  def relationships, do: [feedback: FeedbackView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
