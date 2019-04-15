defmodule WebCATWeb.API.FeedbackController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.Feedback.{Category, StudentFeedback}

  alias WebCAT.Repo
  import Ecto.Query

  def show(_conn, %{rotation_group_id: group_id, user_id: user_id, feedback_id: feedback_id}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      from(feedback in StudentFeedback,
        where: feedback.rotation_group_id == ^group_id,
        where: feedback.user_id == ^user_id,
        where: feedback.feedback_id == ^feedback_id
      )
      |> Repo.one()
      |> case do
        nil -> %{error: "Not Found"}
        feedback -> Map.take(feedback, ~w(content)a)
      end
    end
  end

  def update(conn, %{rotation_group_id: group_id, user_id: user_id, feedback_id: feedback_id, checked: checked?}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
    end
  end
end
