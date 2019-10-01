defmodule WebCATWeb.EmailController do
  alias WebCATWeb.EmailView
  alias WebCAT.Feedback.Email

  use WebCATWeb.ResourceController,
    schema: Email,
    view: EmailView,
    type: "email",
    filter: ~w(draft_id),
    sort: ~w(status draft_id)
end
