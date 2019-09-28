defmodule WebCATWeb.CommentController do
  alias WebCATWeb.CommentView
  alias WebCAT.Feedback.Comment

  use WebCATWeb.ResourceController,
    schema: Comment,
    view: CommentView,
    type: "comment",
    filter: ~w(draft_id user_id),
    sort: ~w(content draft_id user_id inserted_at updated_at)
end
