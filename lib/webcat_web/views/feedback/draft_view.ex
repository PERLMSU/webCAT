defmodule WebCATWeb.DraftView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "draft", collection: "drafts"
  alias WebCATWeb.{UserView, RotationGroupView, CommentView, GradeView}

  def fields,
    do:
      ~w(content notes status inserted_at updated_at)a ++ ~w(parent_draft_id student_id rotation_group_id)a

  def relationships do
    [
      parent_draft: __MODULE__,
      student: UserView,
      rotation_group: RotationGroupView,
      comments: CommentView,
      grades: GradeView
    ]
  end

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
