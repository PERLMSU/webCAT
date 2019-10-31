defmodule WebCATWeb.StudentExplanationView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "student_explanation", collection: "student_explanations"

  alias WebCATWeb.{DraftView, CategoryView, ObservationView, FeedbackView, ExplanationView}

  def fields,
    do: ~w(id inserted_at updated_at)a ++ ~w(draft_id feedback_id explanation_id)a

  def relationships,
    do: [
      draft: DraftView,
      category: CategoryView,
      observation: ObservationView,
      feedback: FeedbackView,
      explanation: ExplanationView,
    ]

  def inserted_at(data, _), do: to_unix_millis(data.inserted_at)
  def updated_at(data, _), do: to_unix_millis(data.updated_at)
end
