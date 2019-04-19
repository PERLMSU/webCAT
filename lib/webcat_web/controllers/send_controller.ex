defmodule WebCATWeb.SendController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.Feedback.{Draft, Drafts}
  alias WebCATWeb.Email
  alias WebCAT.Mailer
  alias WebCAT.Repo
  import Ecto.Query

  def create(conn, user, _params) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      drafts =
        from(draft in Draft,
          where: draft.status == "approved",
          left_join: comments in assoc(draft, :comments),
          left_join: rotation_group in assoc(draft, :rotation_group),
          left_join: user in assoc(draft, :user),
          left_join: grades in assoc(draft, :grades),
          left_join: category in assoc(grades, :category),
          left_join: comment_users in assoc(comments, :user),
          preload: [
            rotation_group: rotation_group,
            user: user,
            grades: {grades, category: category},
            comments: {comments, user: comment_users}
          ]
        )
        |> Repo.all()

      Enum.map(drafts, fn draft ->
        Email.draft(draft)
        |> Mailer.deliver_later()
      end)

      from(d in Draft, where: d.id in ^Enum.map(drafts, &Map.fetch!(&1, :id)))
      |> Repo.update_all(set: [status: "emailed"])

      conn
      |> redirect(to: Routes.inbox_path(conn, :index))
    end
  end
end
