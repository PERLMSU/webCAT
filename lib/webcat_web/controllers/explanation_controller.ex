defmodule WebCATWeb.ExplanationController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.ExplanationView
  alias WebCAT.Feedback.Explanation
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(content feedback_id)a,
    filter: ~w(feedback_id)a,
    fields: Explanation.__schema__(:fields),
    include: Explanation.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(ExplanationView)
    |> render("list.json", explanations: CRUD.list(Explanation, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, explanation} <- CRUD.get(Explanation, id, query) do
      conn
      |> put_status(200)
      |> put_view(ExplanationView)
      |> render("show.json", explanation: explanation)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, explanation} <- CRUD.create(Explanation, params) do
      conn
      |> put_status(201)
      |> put_view(ExplanationView)
      |> render("show.json", explanation: explanation)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create explanation")}

      {:error, _} = it ->
        it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Explanation, id, params) do
      conn
      |> put_status(200)
      |> put_view(ExplanationView)
      |> render("show.json", explanation: updated)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to update explanation")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Explanation, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete explanation")}

      {:error, _} = it ->
        it
    end
  end
end
