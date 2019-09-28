defmodule WebCATWeb.GradeController do
  alias WebCATWeb.GradeView
  alias WebCAT.Feedback.Grade

  use WebCATWeb.ResourceController,
    schema: Grade,
    view: GradeView,
    type: "grade",
    filter: ~w(draft_id category_id),
    sort: ~w(score note draft_id category_id inserted_at updated_at)
end
