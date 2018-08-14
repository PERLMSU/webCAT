defmodule WebCATWeb.ErrorView do
  @moduledoc """
  Render errors to JSON
  """

  use WebCATWeb, :view

  def render("400.json", %{message: message}) do
    case message do
      %{} ->
        %{
          errors: message
        }

      _ ->
        %{
          errors: %{
            detail: message
          }
        }
    end
  end

  def render("401.json", %{message: message}) do
    %{
      errors: %{
        detail: "unauthorized",
        message: message
      }
    }
  end

  def render("403.json", %{message: message}) do
    %{
      errors: %{
        detail: "forbidden",
        message: message
      }
    }
  end

  def render("404.json", %{message: message}) do
    %{
      errors: %{
        detail: "not found",
        message: message
      }
    }
  end

  def render("500.json", _assigns) do
    %{
      errors: %{
        detail: "Internal server error",
        message: "Internal server error"
      }
    }
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.json", assigns)
  end
end
