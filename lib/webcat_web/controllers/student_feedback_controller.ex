defmodule WebCATWeb.StudentFeedbackController do
  alias WebCATWeb.StudentFeedbackView
  alias WebCAT.Feedback.StudentFeedback

  use WebCATWeb.ResourceController,
    schema: StudentFeedback,
    view: StudentFeedbackView,
    type: "student_feedback",
    filter: ~w(draft_id feedback_id),
    sort: ~w(draft_id feedback_id inserted_at updated_at)
end
