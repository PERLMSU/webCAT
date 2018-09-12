defmodule WebCATWeb.CategoryController do
  use WebCATWeb, :controller

  alias WebCAT.Feedback.Categories
  alias WebCATWeb.{CategoryView, ObservationView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :list_categories, user),
         categories <- Categories.list(limit: limit, offset: offset) do
      conn
      |> render(CategoryView, "list.json", categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, category} <- Categories.get(id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :show_category, user, category) do
      conn
      |> render(CategoryView, "show.json", category: category)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :create_category, user),
         {:ok, category} <- Categories.create(params) do
      conn
      |> put_status(:created)
      |> render(CategoryView, "show.json", category: category)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_category} <- Categories.get(id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :update_category, user, subject_category),
         {:ok, updated} <- Categories.update(subject_category.id, params) do
      conn
      |> render(CategoryView, "show.json", category: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_category} <- Categories.get(id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :delete_category, user, subject_category),
         {:ok, _} <- Categories.delete(subject_category.id) do
      send_resp(conn, :ok, "")
    end
  end

  def observations(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_category} <- Categories.get(id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :delete_category, user, subject_category),
         {:ok, observations} <-
           Categories.observations(subject_category.id, limit: limit, offset: offset) do
      conn
      |> render(ObservationView, "list.json", observations: observations)
    end
  end
end
