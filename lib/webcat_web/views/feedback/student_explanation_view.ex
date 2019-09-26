defmodule WebCATWeb.StudentExplanationView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "student_explanation", collection: "student_explanations"

  alias WebCATWeb.{DraftView, FeedbackView, ExplanationView}

  def fields,
    do: ~w(inserted_at updated_at)a ++ ~w(draft_id feedback_id explanation_id)a

  def relationships,
    do: [
      draft: DraftView,
      feedback: FeedbackView,
      explanation: ExplanationView
    ]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
