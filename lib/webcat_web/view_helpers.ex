defmodule WebCATWeb.ViewHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """
  use Phoenix.HTML

  alias WebCAT.CRUD

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

  def table_body(data, options \\ []) do
    route_function = Keyword.fetch!(options, :route_function)

    if not Enum.empty?(data) do
      keys = Keyword.get(options, :keys, Map.keys(hd(data)))

      content_tag(:tbody) do
        Enum.map(data, fn element ->
          content_tag(:tr) do
            Enum.map(keys, fn field ->
              if field == :id do
                content_tag(:td) do
                  icon_button("Show", "wrench",
                    to: route_function.(WebCATWeb.Endpoint, :show, element.id),
                    class: "is-primary"
                  )
                end
              else
                content_tag(:td, element[field])
              end
            end) ++
              content_tag(:td) do
                icon_button("Edit", "wrench",
                  to: route_function.(WebCATWeb.Endpoint, :edit, element.id),
                  class: "is-primary"
                )
              end
          end
        end)
      end
    else
      content_tag(:tr) do
        content_tag(:td, "There are no #{Keyword.get(options, :collection, "entries")} currently")
      end
    end
  end

  def table_header(headers) do
    content_tag(:thead) do
      Enum.map(headers, fn header ->
        if header == :id do
          content_tag(:th, "")
        else
          content_tag(:th, title_case(header))
        end
      end) ++ content_tag(:th, "")
    end
  end

  def table_footer(headers) do
    content_tag(:tfoot) do
      Enum.map(headers, fn header ->
        content_tag(:th, title_case(header))
      end) ++ content_tag(:th, "")
    end
  end

  @doc """
  Uses schema reflection to create a form for a given changeset

  ## Options

    * `:route_name` - The function for getting the route
  """
  def generate_form(changeset, options \\ []) do
    # Grab schema information using reflection
    schema_module = changeset.data.__struct__
    schema_fields = apply(schema_module, :__schema__, [:fields])
    schema_associations = apply(schema_module, :__schema__, [:associations])

    # Use all fields besides auto generated
    keys =
      changeset.data
      |> Map.drop(~w(id updated_at inserted_at)a)
      |> Map.keys()

    fields =
      keys
      |> Enum.filter(fn field ->
        field in schema_fields
      end)
      |> Enum.sort()

    associations =
      keys
      |> Enum.filter(fn field ->
        field in schema_associations
      end)
      |> Enum.map(fn association ->
        apply(schema_module, :__schema__, [:association, association])
      end)
      |> Enum.filter(fn association ->
        association.relationship == :parent
      end)
      |> Enum.sort()

    route_name = Keyword.fetch!(options, :route_name)

    route =
      case changeset.data.id do
        nil ->
          apply(WebCATWeb.Router.Helpers, String.to_atom("#{route_name}_path"), [
            WebCATWeb.Endpoint,
            :create
          ])

        _ ->
          apply(WebCATWeb.Router.Helpers, String.to_atom("#{route_name}_path"), [
            WebCATWeb.Endpoint,
            :update,
            changeset.data.id
          ])
      end

    form_for(changeset, route, fn form ->
      Enum.map(fields, fn field ->
        type = apply(schema_module, :__schema__, [:type, field])
        form_field(form, field, type)
      end) ++
        Enum.map(associations, fn association ->
          association_field(form, association, changeset)
        end) ++ content_tag(:div, class: "field") do
          content_tag(:div, class: "control") do
            submit("Submit", class: "button")
          end
        end
    end)
  end

  @doc """

  """
  def form_field(form, field, type) when type in ~w(string datetime date)a do
    content_tag(:div, class: "field") do
      [
        label(form, field, title_case(field), class: "label"),
        content_tag(:div, class: "control") do
          case type do
            :string -> text_input(form, field, class: "input")
            :date -> date_input(form, field, class: "input")
            :datetime -> date_input(form, field, class: "input")
          end
        end,
        error_tag(form, field)
      ]
    end
  end

  @doc """
  Generates the html for an association field

  ## Options

    * `:route_function` - The function for getting the route
  """
  def association_field(form, association, changeset) do
    module = association.queryable
    data = CRUD.list(module)

    content_tag(:div, class: "field") do
      [
        label(form, association, title_case(association), class: "label"),
        content_tag(:div, class: "control") do
          select(
            form,
            association.owner_key,
            Enum.map(data, &{apply(module, :title_for, [&1]), &1.id}),
            selected:
              if(changeset.data[association.owner_key] != nil,
                do: Integer.to_string(changeset.data[association.owner_key])
              )
          )
        end
      ]
    end
  end

  def escape(string) do
    html_escape(string)
    |> safe_to_string()
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
