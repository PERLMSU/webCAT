defmodule WebCATWeb.ObservationController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.ObservationView
  alias WebCAT.Feedback.Observation
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(content type category_id)a,
    filter: ~w(category_id type)a,
    fields: Observation.__schema__(:fields),
    include: Observation.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(ObservationView)
    |> render("list.json", observations: CRUD.list(Observation, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, observation} <- CRUD.get(Observation, id, query) do
      conn
      |> put_status(200)
      |> put_view(ObservationView)
      |> render("show.json", observation: observation)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, observation} <- CRUD.create(Observation, params) do
      conn
      |> put_status(201)
      |> put_view(ObservationView)
      |> render("show.json", observation: observation)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create observation")}

      {:error, _} = it ->
        it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Observation, id, params) do
      conn
      |> put_status(200)
      |> put_view(ObservationView)
      |> render("show.json", observation: updated)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to update observation")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Observation, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete observation")}

      {:error, _} = it ->
        it
    end
  end
end
