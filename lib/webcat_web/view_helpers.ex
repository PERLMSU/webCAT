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
      content_tag(:p, error, class: "help is-danger")
    end)
  end

  def icon_button(text, icon, opts \\ []) do
    to = Keyword.get(opts, :to, "")
    class = Keyword.get(opts, :class, "")

    icon_class =
      case Keyword.get(opts, :style, :regular) do
        :regular -> "far"
        :solid -> "fas"
        :light -> "fal"
        :brand -> "fab"
        _ -> "far"
      end

    on_click = Keyword.get(opts, :onclick, "")

    content_tag(:a, href: to, class: "button #{class}", onclick: on_click) do
      [
        content_tag(:span, class: "icon") do
          content_tag(:i, "", class: "#{icon_class} fa-#{icon}")
        end,
        content_tag(:span, text)
      ]
    end
  end

  defmacro form_field(label, field, type \\ :text) do
    block =
      case type do
        :textarea ->
          quote do
            textarea(var!(f), unquote(field), class: "input")
          end

        :text ->
          quote do
            text_input(var!(f), unquote(field), class: "input")
          end

        :phone ->
          quote do
            telephone_input(var!(f), unquote(field), class: "input")
          end

        :date ->
          quote do
            date_input(var!(f), unquote(field), class: "input")
          end
      end

    quote do
      content_tag(:div, class: "field") do
        [
          label(var!(f), unquote(field), unquote(label)),
          content_tag(:div, class: "control") do
            unquote(block)
          end,
          error_tag(var!(f), unquote(field))
        ]
      end
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
        String.slice(string, 0..length-3) <> "..."

      true ->
        string
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
end
