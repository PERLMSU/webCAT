defmodule WebCATWeb.StudentExplanationController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.StudentExplanationView
  alias WebCAT.Feedback.StudentExplanation
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(
        conn,
        _user,
        %{
          "rotation_group_id" => _,
          "student_id" => _,
        } = params
      ) do
    conn
    |> put_status(200)
    |> put_view(StudentExplanationView)
    |> render("list.json",
      student_explanations:
        CRUD.list(
          StudentExplanation,
          filter(params, ~w(rotation_group_id student_id))
        )
    )
  end

  def create(conn, _user, %{
        "rotation_group_id" => group_id,
        "student_id" => student_id,
        "feedback_id" => feedback_id,
        "explanation_id" => explanation_id
      }) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, student_explanation} <-
           StudentExplanation.add(group_id, student_id, feedback_id, explanation_id) do
      conn
      |> put_status(201)
      |> put_view(StudentExplanationView)
      |> render("show.json", student_explanation: student_explanation)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create student explanation")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{
        "rotation_group_id" => group_id,
        "student_id" => student_id,
        "feedback_id" => feedback_id,
        "explanation_id" => explanation_id
      }) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         :ok <- StudentExplanation.delete(group_id, student_id, feedback_id, explanation_id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete student explanation")}

      {:error, _} = it ->
        it
    end
  end
end
