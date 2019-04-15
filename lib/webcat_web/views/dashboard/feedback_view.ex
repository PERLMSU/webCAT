defmodule WebCATWeb.FeedbackView do
  use WebCATWeb, :dashboard_view

  import Ecto.Changeset
  alias WebCAT.CRUD
  alias WebCAT.Feedback.Observation
end
