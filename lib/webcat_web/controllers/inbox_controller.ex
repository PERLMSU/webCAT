defmodule WebCATWeb.InboxController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.Repo
  import Ecto.Query

  alias WebCAT.Feedback.{Draft, Criteria, Grade, Observation}
  alias WebCAT.Rotations.{Student}
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)
end
