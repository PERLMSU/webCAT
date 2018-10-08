defmodule WebCATWeb.ViewHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """
  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    if error = form.errors[field] do
      {message, _} = error
      content_tag(:p, message, class: "help is-danger")
    else
      ""
    end
  end

  def icon_button(text, icon, opts \\ []) do
    to = Keyword.get(opts, :to, "")
    class = Keyword.get(opts, :class, "")

    content_tag(:a, href: to, class: "button #{class}") do
      [
        content_tag(:span, class: "icon") do
          content_tag(:i, "", class: "fas fa-#{icon}")
        end,
        content_tag(:span, text)
      ]
    end
  end

  def form_field(form, field, type) when type in ~w(text textarea date)a do
    content_tag(:div, class: "field") do
      [
        label(form, field, humanize(field), class: "label"),
        content_tag(:div, class: "control") do
          case type do
            :text -> text_input(form, field, class: "input")
            :textarea -> textarea(form, field, class: "input")
            :date -> date_input(form, field, class: "input")
          end
        end,
        error_tag(form, field)
      ]
    end
  end

  def escape(string) do
    html_escape(string)
    |> safe_to_string()
  end
end
