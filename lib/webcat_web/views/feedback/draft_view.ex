defmodule WebCATWeb.DraftView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.Draft
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.Accounts.User
  alias WebCATWeb.{UserView, RotationGroupView, CommentView, GradeView}

  def render("list.json", %{drafts: drafts}) do
    render_many(drafts, __MODULE__, "draft.json")
  end

  def render("show.json", %{draft: draft}) do
    render_one(draft, __MODULE__, "draft.json")
  end

  def render("draft.json", %{draft: %Draft{} = draft}) do
    draft
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{user: %User{} = user} = map ->
        Map.put(map, :user, render_one(user, UserView, "user.json"))

      map ->
        Map.delete(map, :user)
    end
    |> case do
      %{rotation_group: %RotationGroup{} = group} = map ->
        Map.put(map, :rotation_group, render_one(group, RotationGroupView, "group.json"))

      map ->
        Map.delete(map, :rotation_group)
    end
    |> case do
      %{comments: comments} = map when is_list(comments) ->
        Map.put(map, :comments, render_many(comments, CommentView, "comment.json"))

      map ->
        Map.delete(map, :comments)
    end
    |> case do
      %{grades: grades} = map when is_list(grades) ->
        Map.put(map, :grades, render_many(grades, GradeView, "grade.json"))

      map ->
        Map.delete(map, :grades)
    end
  end
end
