defmodule WebCATWeb.CommentView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.{Comment, Draft}
  alias WebCAT.Accounts.User
  alias WebCATWeb.{DraftView, UserView}

  def render("list.json", %{comments: comments}) do
    render_many(comments, __MODULE__, "comment.json")
  end

  def render("show.json", %{comment: comment}) do
    render_one(comment, __MODULE__, "comment.json")
  end

  def render("comment.json", %{comment: %Comment{} = comment}) do
    comment
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{draft: %Draft{} = draft} = map ->
        Map.put(map, :draft, render_one(draft, DraftView, "draft.json"))

      map ->
        Map.delete(map, :draft)
    end
    |> case do
      %{user: %User{} = user} = map ->
        Map.put(map, :user, render_one(user, UserView, "user.json"))

      map ->
        Map.delete(map, :user)
    end
  end
end
