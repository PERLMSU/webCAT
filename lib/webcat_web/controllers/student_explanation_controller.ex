defmodule WebCATWeb.StudentExplanationController do
  alias WebCATWeb.StudentExplanationView
  alias WebCAT.Feedback.StudentExplanation

  use WebCATWeb.ResourceController,
    schema: StudentExplanation,
    view: StudentExplanationView,
    type: "student_explanation",
    filter: ~w(draft_id feedback_id explanation_id),
    sort: ~w(draft_id feedback_id explanation_id inserted_at updated_at)
end
