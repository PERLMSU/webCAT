defmodule WebCATWeb.CategoriesController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  alias WebCAT.Feedback.Category
  alias WebCAT.CRUD


  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :list_categories, user),
         categories <- CRUD.list(Category) do
      render(conn, "index.html", conn: conn, user: user, categories: categories)
    end
  end
end

