defmodule WebCATWeb.CommentController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.Repo
  alias WebCAT.Feedback.Comment

  def create(conn, user, %{"comment" => comment, "draft_id" => draft_id}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      case(
        Comment.changeset(%Comment{draft_id: String.to_integer(draft_id)}, comment)
        |> Repo.insert()
      ) do
        {:ok, comment} -> redirect(conn, to: Routes.inbox_path(conn, :show, comment.draft_id))
        {:error, changeset} -> {:error, changeset}
      end
    end
  end
end
