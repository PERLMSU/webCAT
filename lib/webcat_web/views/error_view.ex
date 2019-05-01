defmodule WebCATWeb.ErrorView do
  use WebCATWeb, :view

  def render("400.json", assigns) do
    %{error: "Malformed request", details: Map.drop(assigns, ~w(conn view_module view_template)a)}
  end

  def render("401.json", assigns) do
    %{error: "Unauthorized", details: Map.drop(assigns, ~w(conn view_module view_template)a)}
  end

  def render("403.json", assigns) do
    %{error: "Forbidden", details: Map.drop(assigns, ~w(conn view_module view_template)a)}
  end

  def render("404.json", assigns) do
    %{error: "404 Not Found", details: Map.drop(assigns, ~w(conn view_module view_template)a)}
  end

  def render("500.json", assigns) do
    %{
      error: "Internal server error",
      details: Map.drop(assigns, ~w(conn view_module view_template)a)
    }
  end
end
