defmodule WebCATWeb.ViewHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """
  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn {error, _} ->
      content_tag(:div, error, class: "ui error message")
    end)
  end

  def icon_button(text, icon, opts \\ []) do
    to = Keyword.get(opts, :to, "")
    class = Keyword.get(opts, :class, "")

    on_click = Keyword.get(opts, :onclick, "")

    content_tag(:a, href: to, class: "ui button #{class}", onclick: on_click) do
      [
        content_tag(:i, "", class: "icon far fa-#{icon}"),
        text
      ]
    end
  end

  def form_field(form, label, field, type \\ :text, options \\ []) do
    field_class =
      if Keyword.get(options, :required, false) do
        "required field"
      else
        "field"
      end

    content_tag(:div, class: field_class) do
      [
        label(form, field, label),
        content_tag(:div, class: "control") do
          case type do
            :textarea ->
              textarea(form, field, class: "input")

            :text ->
              text_input(form, field, class: "input")

            :phone ->
              telephone_input(form, field, class: "input")

            :date ->
              date_input(form, field, class: "input")

            :number ->
              number_input(form, field, class: "input")
          end
        end,
        error_tag(form, field)
      ]
    end
  end

  def statistic(value, label) do
    content_tag(:div, class: "ui statistic") do
      [
        content_tag(:div, class: "value") do
          value
        end,
        content_tag(:div, class: "label") do
          label
        end
      ]
    end
  end

  def escape(string) do
    html_escape(string)
    |> safe_to_string()
  end

  def truncate(string, length \\ 25) do
    cond do
      string == nil ->
        ""

      String.length(string) > length ->
        String.slice(string, 0..(length - 3)) <> "..."

      true ->
        string
    end
  end

  def select_field(form, label, field, data, options \\ []) do
    field_class =
      if Keyword.get(options, :required, false) do
        "required field"
      else
        "field"
      end

    select_class =
      if Keyword.get(options, :search, false) do
        "ui search dropdown"
      else
        "ui dropdown"
      end

    field_value = Map.get(form.data, field)

    content_tag(:div, class: field_class) do
      [
        label(form, field, label),
        select(form, field, data,
          selected: field_value,
          prompt: Keyword.get(options, :prompt, "None"),
          class: select_class
        )
      ]
    end
  end

  def multi_select_field(form, label, field, data, options \\ []) do
    field_value = Map.get(form.data, field)

    select_class =
      if Keyword.get(options, :search, false) do
        "ui fluid search dropdown"
      else
        "ui fluid dropdown"
      end

    content_tag(:div, class: "field") do
      [
        label(form, field, label),
        multiple_select(form, field, data,
          selected:
            if(is_list(field_value),
              do: Enum.map(field_value, & &1.id),
              else: []
            ),
          size: Enum.count(data),
          prompt: Keyword.get(options, :prompt, "None"),
          class: select_class
        )
      ]
    end
  end

  @doc """
  Title cases a string where words are separated by underscores

  ## Examples

    iex> WebCATWeb.CRUDView.title_case("this_should_be_title_cased")
    "This Should Be Title Cased"
    iex> WebCATWeb.CRUDView.title_case("this_is_a_word_that_is_not_capitalized")
    "This is a Word That is Not Capitalized"
  """
  def title_case(string) when is_binary(string) do
    string
    |> String.split("_")
    |> Enum.map(fn word ->
      if word not in ~w(a an the and but for at by from is) do
        String.capitalize(word)
      else
        word
      end
    end)
    |> Enum.join(" ")
  end

  @doc """
  Title cases an atom where words are separated by underscores

  ## Examples

    iex> WebCATWeb.CRUDView.title_case(:this_should_be_title_cased)
    "This Should Be Title Cased"
    iex> WebCATWeb.CRUDView.title_case(:this_is_a_word_that_is_not_capitalized)
    "This is a Word That is Not Capitalized"
  """
  def title_case(atom) when is_atom(atom), do: title_case(Atom.to_string(atom))

  def breadcrumbs(entries) do
    content_tag(:div, class: "ui breadcrumb", aria: [label: "breadcrumbs"]) do
      Enum.intersperse(entries, content_tag(:i, "", class: "right angle icon divider"))
    end
  end

  def breadcrumb(text, options \\ []) do
    case Keyword.get(options, :to) do
      nil -> content_tag(:div, text, class: "active section")
      link -> link(text, to: link, class: "section")
    end
  end
end
