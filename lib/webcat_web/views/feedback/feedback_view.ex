defmodule WebCATWeb.FeedbackView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "feedback", collection: "feedback"

  alias WebCATWeb.{ObservationView, ExplanationView}

  def fields, do: ~w(content inserted_at updated_at)a ++ ~w(observation_id)a

  def relationships, do: [explanations: ExplanationView, observation: ObservationView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
