defmodule WebCATWeb.DraftController do
  alias WebCATWeb.{DraftView, EmailView}
  alias WebCAT.Feedback.{Draft, Email}
  alias WebCAT.Repo
  alias WebCAT.Mailer

  use WebCATWeb.ResourceController,
    schema: Draft,
    view: DraftView,
    type: "draft",
    filter: ~w(status parent_draft_id student_id rotation_group_id),
    sort: ~w(status parent_draft_id student_id rotation_group_id inserted_at updated_at)

  def send_email(conn, user, %{"id" => id}) do
    with {:auth, true} <- {:auth, user.role in ~w(admin)},
         {:ok, draft} <-
           CRUD.get(Draft, id, include: [:grades, child_drafts: ~w(student grades parent_draft)a]) do
      emails =
        draft.child_drafts
        |> Enum.map(fn draft -> {draft, WebCATWeb.Email.draft(draft)} end)
        |> Enum.map(fn {draft, email} -> {draft, Mailer.deliver_now(email)} end)
        |> Enum.map(fn {draft, _response} ->
          Repo.insert!(Email.changeset(%Email{}, %{status: "sent", draft_id: draft.id}))
        end)

      conn
      |> put_status(:ok)
      |> put_view(EmailView)
      |> render("index.json", %{data: emails})
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to send email")}

      {:error, _} = it ->
        it
    end
  end
end
