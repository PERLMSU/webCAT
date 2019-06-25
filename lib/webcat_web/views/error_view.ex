defmodule WebCATWeb.ErrorView do
  use WebCATWeb, :view

  def render("400.html", _assigns) do
    "Server internal error"
  end

  def render("404.html", _assigns) do
    "Not found"
  end

  def render("500.html", _assigns) do
    "Server internal error"
  end
end
