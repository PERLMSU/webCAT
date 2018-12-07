defmodule WebCATWeb.Macros.Dashboard do
  @moduledoc """
  Generates necessary view methods for a dashboardable item
  """
  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML

  defmacro __using__(options) do
    {_, _, m} = Keyword.fetch!(options, :schema)
    schema = Module.safe_concat(m)
    item_name = String.downcase(Keyword.fetch!(options, :item_name))
    collection_name = Keyword.fetch!(options, :collection_name)

    route_name =
      Keyword.get(
        options,
        :route_name,
        String.split(item_name, " ") |> Enum.join("_") |> String.downcase()
      )

    quote do
      use Phoenix.View,
        root: "lib/webcat_web/templates",
        path: "dashboard",
        namespace: WebCATWeb

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      alias WebCATWeb.Router.Helpers, as: Routes

      unquote(generate_form(schema, route_name))

      unquote(table_head(schema, :header))

      unquote(table_head(schema, :footer))

      unquote(table_body(schema))

      unquote(display(schema))

      def title_for(data), do: unquote(schema).title_for(data)

      def collection(), do: unquote(schema.__schema__(:source))

      def collection_name(), do: unquote(collection_name)

      def item_name(), do: unquote(item_name)

      defp error_tag(form, field) do
        if error = form.errors[field] do
          {message, _} = error
          content_tag(:p, message, class: "help is-danger")
        else
          ""
        end
      end

      def action_button(action, opts) do
        conn = Keyword.get(opts, :conn, WebCATWeb.Endpoint)

        case action do
          :show ->
            to = Routes.unquote(:"#{route_name}_path")(conn, :show, Keyword.fetch!(opts, :id))
            unquote(icon_button("Show", icon: "wrench", class: "is-primary"))

          :new ->
            to = Routes.unquote(:"#{route_name}_path")(conn, :new)
            unquote(icon_button("New", icon: "plus", class: "is-error"))

          :edit ->
            to = Routes.unquote(:"#{route_name}_path")(conn, :edit, Keyword.fetch!(opts, :id))
            unquote(icon_button("Edit", icon: "wrench", class: "is-primary"))

          :delete ->
            to = Routes.unquote(:"#{route_name}_path")(conn, :delete, Keyword.fetch!(opts, :id))

            unquote(icon_button("Delete", icon: "plus", class: "is-error"))

          _ ->
            raise "Invalid action supplied to action_button: #{Atom.to_string(action)}"
        end
      end
    end
  end

  def display(schema) do
    display_keys =
      schema.__struct__
      |> schema.display()
      |> Map.keys()

    schema_fields = schema.__schema__(:fields)
    schema_associations = schema.__schema__(:associations)

    field_html =
      schema_fields
      |> Enum.filter(&(&1 in display_keys))
      |> Enum.map(fn field ->
        field_name =
          field
          |> Atom.to_string()
          |> String.split("_")
          |> Enum.join(" ")
          |> String.capitalize()

        quote do
          content_tag(:div) do
            content_tag(:p, unquote(field_name))
            content_tag(:p, Map.fetch!(formatted, unquote(field)))
          end
        end
      end)

    association_html =
      schema_associations
      |> Enum.filter(&(&1 in display_keys))
      |> Enum.map(fn field ->
        association = schema.__schema__(:association, field)

        assoc_route_name = ""

        case association.__struct__ do
          Ecto.Association.BelongsTo ->
            quote do
              content_tag(:div) do
                to = Routes.unquote(:"#{assoc_route_name}_path")(conn, :show, element.id)
                unquote(icon_button("Show", icon: "wrench", class: "is-primary"))
              end
            end

          Ecto.Association.NotLoaded ->
            []

          _ ->
            quote do
              content_tag(:div) do
                [
                  content_tag(:p, unquote(String.capitalize(Atom.to_string(field)))),
                  content_tag(:ul) do
                    Enum.map(Map.fetch!(formatted, unquote(field)), fn element ->
                        content_tag(:li) do
                          to = Routes.unquote(:"#{assoc_route_name}_path")(conn, :show, element.id)
                          unquote(icon_button("Show", icon: "wrench", class: "is-primary"))
                        end
                    end)
                  end
                ]
              end
            end
        end
      end)

    quote do
      def display(data) do
        formatted = unquote(schema).display(data)

        content_tag(:div) do
          unquote(field_html) ++ unquote(association_html)
        end
      end
    end
  end

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

  def title_case(atom) when is_atom(atom), do: title_case(Atom.to_string(atom))

  def table_body(schema) do
    keys = schema.table_fields()

    id_col =
      quote do
        content_tag(:td) do
          action_button(:show, id: element.id)
        end
      end

    columns =
      Enum.map(keys, fn key ->
        quote do
          content_tag(:td, Map.get(element, unquote(key)))
        end
      end)

    edit_col =
      quote do
        content_tag(:td) do
          action_button(:edit, id: element.id)
        end
      end

    quote do
      def table_body(data, options \\ []) do
        conn = Keyword.get(options, :conn, WebCATWeb.Endpoint)

        content_tag(:tbody) do
          Enum.map(data, fn element ->
            content_tag(:tr) do
              [unquote(id_col), unquote(columns), unquote(edit_col)]
            end
          end)
        end
      end
    end
  end

  def generate_form(schema, route_name, opts \\ []) do
    # Generate a form structure for a given schema
    # Relies on conn and changeset existing in the scope this is unquoting into

    schema_fields = schema.__schema__(:fields)
    schema_associations = schema.__schema__(:associations)

    excluded_keys = Keyword.get(opts, :excluded_keys, ~w(updated_at inserted_at)a)

    {id_col, _, _} = schema.__schema__(:autogenerate_id)

    # Use all fields besides those explicitly excluded and the id column
    keys =
      schema.__struct__
      |> Map.from_struct()
      |> Map.drop(~w(__meta__)a ++ excluded_keys ++ [id_col])
      |> Map.keys()

    fields =
      Enum.filter(
        keys,
        fn field ->
          not String.ends_with?(Atom.to_string(field), "_id") and field not in schema_associations
        end
      )

    associations = Enum.map(schema_associations, &schema.__schema__(:association, &1))

    # Generate the field form AST
    field_html =
      Enum.map(
        fields,
        fn field ->
          type = schema.__schema__(:type, field)

          input =
            case type do
              :string -> quote(do: text_input(form, unquote(field), class: "input"))
              :integer -> quote(do: number_input(form, unquote(field), class: "input"))
              :date -> quote(do: date_input(form, unquote(field), class: "input"))
              :datetime -> quote(do: date_input(form, unquote(field), class: "input"))
              :boolean -> quote(do: checkbox(form, unquote(field)))
            end

          quote do
            content_tag(:div, class: "field") do
              [
                label(form, unquote(field), unquote(title_case(field)), class: "label"),
                content_tag(:div, class: "control") do
                  unquote(input)
                end,
                error_tag(form, unquote(field))
              ]
            end
          end
        end
      )

    # Generate the association form AST
    association_html =
      Enum.map(
        associations,
        fn association ->
          case association.__struct__ do
            Ecto.Association.BelongsTo ->
              quote do
                data = WebCAT.CRUD.list(unquote(association.queryable))

                content_tag(:div, class: "field") do
                  [
                    label(
                      form,
                      unquote(association.field),
                      unquote(title_case(association.field)),
                      class: "label"
                    ),
                    content_tag(:div, class: "control") do
                      select(
                        form,
                        unquote(association.owner_key),
                        [{"None", nil}] ++
                          (Enum.map(data, &{unquote(association.queryable).title_for(&1), &1.id})
                           |> Enum.filter(fn {_title, id} ->
                             Map.get(changeset.data, unquote(association.owner_key)) != id
                           end)),
                        selected:
                          if(Map.get(changeset.data, unquote(association.owner_key)) != nil,
                            do:
                              Integer.to_string(
                                Map.get(changeset.data, unquote(association.owner_key))
                              )
                          )
                      )
                    end
                  ]
                end
              end

            _ ->
              quote do
                data = WebCAT.CRUD.list(unquote(association.queryable))

                content_tag(:div, class: "field") do
                  [
                    label(
                      form,
                      unquote(association.field),
                      unquote(title_case(association.field)),
                      class: "label"
                    ),
                    content_tag(:div, class: "control") do
                      multiple_select(
                        form,
                        unquote(association.field),
                        Enum.map(data, &{unquote(association.queryable).title_for(&1), &1.id}),
                        selected:
                          if is_list(changeset.data.unquote(association.field)) do
                            Enum.map(changeset.data.unquote(association.field), & &1.id)
                          else
                            []
                          end
                      )
                    end
                  ]
                end
              end
          end
        end
      )

    submit_html =
      content_tag(:div, class: "field") do
        content_tag(:div, class: "control") do
          submit("Submit", class: "button")
        end
      end

    quote do
      def generate_form(changeset, opts \\ []) do
        conn = Keyword.get(opts, :conn, WebCATWeb.Endpoint)

        route =
          case changeset.data.id do
            nil -> Routes.unquote(:"#{route_name}_path")(conn, :create)
            _ -> Routes.unquote(:"#{route_name}_path")(conn, :edit, changeset.data.id)
          end

        form_for(
          changeset,
          route,
          fn form ->
            unquote(field_html) ++ unquote(association_html) ++ unquote(submit_html)
          end
        )
      end
    end
  end

  def table_head(schema, type) when type in ~w(header footer)a do
    class =
      case type do
        :header -> :thead
        :footer -> :tfoot
      end

    html =
      content_tag(class) do
        [content_tag(:th, "")] ++
          Enum.map(
            schema.table_fields(),
            fn header ->
              if header == :id do
                content_tag(:th, "")
              else
                content_tag(:th, title_case(header))
              end
            end
          ) ++ content_tag(:th, "")
      end

    quote do
      def unquote(:"table_#{Atom.to_string(type)}")() do
        unquote(html)
      end
    end
  end

  def icon_button(text, opts \\ []) do
    class = Keyword.get(opts, :class, "")
    icon = Keyword.get(opts, :icon, "")

    quote do
      content_tag :a, href: to, class: unquote("button #{class}") do
        [
          content_tag :span, class: "icon" do
            content_tag(:i, "", class: unquote("fas fa-#{icon}"))
          end,
          content_tag(:span, unquote(text))
        ]
      end
    end
  end
end
