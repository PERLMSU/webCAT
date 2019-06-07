defmodule WebCATWeb.ErrorView do
  use WebCATWeb, :view

  def render("400.json", _assigns) do
    %{
      errors: [
        %{status: "400", title: "Malformed request"}
      ]
    }
  end

  def render("401.json", _assigns) do
    %{
      errors: [
        %{status: "401", title: "Unauthorized"}
      ]
    }
  end

  def render("403.json", _assigns) do
    %{
      errors: [
        %{status: "403", title: "Forbidden"}
      ]
    }
  end

  def render("404.json", _assigns) do
    %{errors: [%{status: "404", title: "Not found"}]}
  end

  def render("500.json", _assigns) do
    %{
      errors: [
        %{
          status: "500",
          title: "Internal server error"
        }
      ]
    }
  end
end
