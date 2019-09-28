defmodule WebCATWeb.DraftController do
  alias WebCATWeb.DraftView
  alias WebCAT.Feedback.Draft

  use WebCATWeb.ResourceController,
    schema: Draft,
    view: DraftView,
    type: "draft",
    filter: ~w(status parent_draft_id student_id rotation_group_id),
    sort: ~w(status parent_draft_id student_id rotation_group_id inserted_at updated_at)
end
