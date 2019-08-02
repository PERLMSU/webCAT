defmodule WebCATWeb.StudentFeedbackController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.StudentFeedbackView
  alias WebCAT.Feedback.StudentFeedback
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, %{"rotation_group_id" => _, "student_id" => _} = params) do
    conn
    |> put_status(200)
    |> put_view(StudentFeedbackView)
    |> render("list.json", student_feedback: CRUD.list(StudentFeedback, filter: filter(params, ~w(rotation_group_id student_id))))
  end

  def create(conn, _user, %{
        "rotation_group_id" => group_id,
        "student_id" => student_id,
        "feedback_id" => feedback_id
      }) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, student_feedback} <- StudentFeedback.add(group_id, student_id, feedback_id) do
      conn
      |> put_status(201)
      |> put_view(StudentFeedbackView)
      |> render("show.json", student_feedback: student_feedback)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create student feedback")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{
        "rotation_group_id" => group_id,
        "student_id" => student_id,
        "feedback_id" => feedback_id
      }) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         :ok <- StudentFeedback.delete(group_id, student_id, feedback_id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete student feedback")}

      {:error, _} = it ->
        it
    end
  end
end
