defmodule WebCATWeb.ErrorView do
  @moduledoc """
  Handles rendering of all the different error states that are possible.
  Also handles translation of changeset errors into something the front end can handle.
  """
  use WebCATWeb, :view
  import WebCATWeb.Gettext

  def render("400.json", assigns) do
    case assigns do
      %{changeset: changeset} ->
        %{errors: translate_errors(changeset)}

      %{message: message} when is_binary(message) ->
        %{error: %{status: "400", title: dgettext("errors", "Bad Request"), message: message}}

      _ ->
        %{error: %{status: "400", title: dgettext("errors", "Bad Request")}}
    end
  end

  def render("401.json", assigns) do
    case assigns do
      %{message: message} when is_binary(message) ->
        %{error: %{status: "401", title: dgettext("errors", "Unauthorized"), message: message}}

      _ ->
        %{error: %{status: "401", title: dgettext("errors", "Unauthorized")}}
    end
  end

  def render("403.json", assigns) do
    case assigns do
      %{message: message} when is_binary(message) ->
        %{error: %{status: "403", title: dgettext("errors", "Forbidden"), message: message}}

      _ ->
        %{error: %{status: "403", title: dgettext("errors", "Forbidden")}}
    end
  end

  def render("404.json", assigns) do
    case assigns do
      %{message: message} when is_binary(message) ->
        %{error: %{status: "404", title: dgettext("errors", "Not Found"), message: message}}

      _ ->
        %{error: %{status: "404", title: dgettext("errors", "Not Found")}}
    end
  end

  def render("500.json", assigns) do
    case assigns do
      %{message: message} when is_binary(message) ->
        %{
          error: %{
            status: "500",
            title: dgettext("errors", "Internal Server Error"),
            message: message
          }
        }

      _ ->
        %{error: %{status: "500", title: dgettext("errors", "Internal Server Error")}}
    end
  end

  def render(_, assigns), do: render("500.json", assigns)

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    case opts[:count] do
      nil ->
        Gettext.dgettext(WebCATWeb.Gettext, "errors", msg, opts)

      count ->
        Gettext.dngettext(WebCATWeb.Gettext, "errors", msg, msg, count, opts)
    end
  end
end
