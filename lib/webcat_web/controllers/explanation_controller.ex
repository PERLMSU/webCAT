defmodule WebCATWeb.ExplanationController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Feedback.Explanation
  alias WebCATWeb.ExplanationView

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :list_explanations, user),
         explanations <- CRUD.list(Explanation, limit: limit, offset: offset) do
      conn
      |> render(ExplanationView, "list.json", explanations: explanations)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, explanation} <- CRUD.get(Explanation, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :show_explanation, user, explanation) do
      conn
      |> render(ExplanationView, "show.json", explanation: explanation)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :create_explanation, user),
         {:ok, explanation} <- CRUD.create(Explanation, params) do
      conn
      |> put_status(:created)
      |> render(ExplanationView, "show.json", explanation: explanation)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_explanation} <- CRUD.get(Explanation, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :update_explanation, user, subject_explanation),
         {:ok, updated} <- CRUD.update(Explanation, subject_explanation.id, params) do
      conn
      |> render(ExplanationView, "show.json", explanation: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_explanation} <- CRUD.get(Explanation, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :delete_explanation, user, subject_explanation),
         {:ok, _} <- CRUD.delete(Explanation, subject_explanation.id) do
      send_resp(conn, :ok, "")
    end
  end
end
