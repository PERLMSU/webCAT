defmodule WebCATWeb.StudentFeedbackView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "student_feedback", collection: "student_feedback"

  alias WebCATWeb.{DraftView, CategoryView, ObservationView, FeedbackView}

  def fields,
    do: ~w(inserted_at updated_at)a ++ ~w(draft_id feedback_id)a

  def relationships,
    do: [
      draft: DraftView,
      category: CategoryView,
      observation: ObservationView,
      feedback: FeedbackView
    ]

  def inserted_at(data, _), do: to_unix_millis(data.inserted_at)
  def updated_at(data, _), do: to_unix_millis(data.updated_at)
end
