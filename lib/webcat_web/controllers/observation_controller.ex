defmodule WebCATWeb.ObservationController do
  alias WebCATWeb.ObservationView
  alias WebCAT.Feedback.Observation

  use WebCATWeb.ResourceController,
    schema: Observation,
    view: ObservationView,
    type: "observation",
    filter: ~w(type category_id),
    sort: ~w(content type category_id inserted_at updated_at)
end
