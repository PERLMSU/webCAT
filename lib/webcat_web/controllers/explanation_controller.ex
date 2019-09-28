defmodule WebCATWeb.ExplanationController do
  alias WebCATWeb.ExplanationView
  alias WebCAT.Feedback.Explanation

  use WebCATWeb.ResourceController,
    schema: Explanation,
    view: ExplanationView,
    type: "explanation",
    filter: ~w(feedback_id),
    sort: ~w(content feedback_id inserted_at updated_at)
end
