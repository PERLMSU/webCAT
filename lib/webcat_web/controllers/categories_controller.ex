defmodule WebCATWeb.CategoriesController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "categories.html")
  end
end

