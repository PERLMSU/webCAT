defmodule WebCATWeb.DraftView do
  @moduledoc """
  Render drafts
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Draft

  def render("list.json", %{drafts: drafts}) do
    render_many(drafts, __MODULE__, "draft.json")
  end

  def render("show.json", %{draft: draft}) do
    render_one(draft, __MODULE__, "draft.json")
  end

  def render("draft.json", %{draft: %Draft{} = draft}) do
    draft
    |> Map.from_struct()
    |> Map.take(~w(id content status student_id rotation_group_id inserted_at updated_at)a)
  end
end
