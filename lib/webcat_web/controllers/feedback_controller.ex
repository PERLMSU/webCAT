defmodule WebCATWeb.FeedbackController do
  alias WebCATWeb.FeedbackView
  alias WebCAT.Feedback.Feedback

  use WebCATWeb.ResourceController,
    schema: Feedback,
    view: FeedbackView,
    type: "feedback",
    filter: ~w(observation_id),
    sort: ~w(content observation_id inserted_at updated_at)
end
