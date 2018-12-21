defmodule WebCATWeb.Macros.View do
  @moduledoc """
  Generates necessary view methods for a dashboardable item
  """
  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML

  def compile_view(env, resources) do
    view_ast =
      Enum.map(resources, fn %{
                               schema: schema,
                               options: [item_name: item_name, collection_name: collection_name]
                             } = resource ->
        quote do
          unquote(compile_generate_form(env, resource))
          unquote(table_head(resource, :header))
          unquote(table_head(resource, :footer))
          unquote(compile_table_body(resource))
          unquote(compile_display(env, resource))

          def title_for(unquote(schema), data),
            do: unquote(env.module).title_for(unquote(schema), data)

          def collection(unquote(schema)), do: unquote(schema.__schema__(:source))
          def collection_name(unquote(schema)), do: unquote(collection_name)
          def item_name(unquote(schema)), do: unquote(item_name)

          unquote(compile_action_button(env, resource))
        end
      end)

    quote do
      use Phoenix.View,
        root: "lib/webcat_web/templates",
        path: "dashboard",
        namespace: unquote(env.module)

      use Phoenix.HTML
      alias WebCATWeb.Router.Helpers, as: Routes
      alias unquote(env.module).Router.Helpers, as: DashboardRoutes

      unquote(compile_dashboard_menu(env, resources))
      unquote(view_ast)

      defp error_tag(form, field) do
        if error = form.errors[field] do
          {message, _} = error
          content_tag(:p, message, class: "help is-danger")
        else
          ""
        end
      end
    end
  end

  def compile_action_button(env, %{
        schema: schema
      }) do
    route_name = WebCATWeb.Macros.Dashboard.get_route_name(env, schema)

    quote do
      def action_button(unquote(schema), action, opts) do
        conn = Keyword.get(opts, :conn, WebCATWeb.Endpoint)

        case action do
          :show ->
            to =
              DashboardRoutes.unquote(:"#{route_name}_path")(
                conn,
                :show,
                Keyword.fetch!(opts, :id)
              )

            unquote(icon_button("Show", icon: "wrench", class: "is-primary"))

          :new ->
            to = DashboardRoutes.unquote(:"#{route_name}_path")(conn, :new)
            unquote(icon_button("New", icon: "plus", class: "is-error"))

          :edit ->
            to =
              DashboardRoutes.unquote(:"#{route_name}_path")(
                conn,
                :edit,
                Keyword.fetch!(opts, :id)
              )

            unquote(icon_button("Edit", icon: "wrench", class: "is-primary"))

          :delete ->
            to =
              DashboardRoutes.unquote(:"#{route_name}_path")(
                conn,
                :delete,
                Keyword.fetch!(opts, :id)
              )

            unquote(icon_button("Delete", icon: "plus", class: "is-error"))

          :import ->
            to =
              DashboardRoutes.unquote(:"#{route_name}_path")(
                conn,
                :import
              )

            unquote(icon_button("Import", icon: "file-import", class: "is-primary"))

          _ ->
            raise "Invalid action for #{unquote(schema)}: #{Atom.to_string(action)}"
        end
      end
    end
  end

  def compile_display(env, %{schema: schema, display_fields: display_keys}) do
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
            [
              content_tag(:h2, class: "title") do
                unquote(field_name)
              end,
              content_tag(:p, Map.fetch!(formatted, unquote(field)))
            ]
          end
        end
      end)

    association_html =
      schema_associations
      |> Enum.filter(&(&1 in display_keys))
      |> Enum.map(fn field ->
        association = schema.__schema__(:association, field)

        assoc_route_name = WebCATWeb.Macros.Dashboard.get_route_name(env, association.queryable)

        case association.__struct__ do
          Ecto.Association.BelongsTo ->
            quote do
              content_tag(:div) do
                to = DashboardRoutes.unquote(:"#{assoc_route_name}_path")(conn, :show, element.id)
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
                        to =
                          DashboardRoutes.unquote(:"#{assoc_route_name}_path")(
                            conn,
                            :show,
                            element.id
                          )

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
      def display_data(unquote(schema), data) do
        formatted = unquote(env.module).display_resource(unquote(schema), data)

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

  def compile_table_body(%{schema: schema, table_fields: fields}) do
    id_col =
      quote do
        content_tag(:td) do
          action_button(unquote(schema), :show, id: element.id)
        end
      end

    columns =
      Enum.map(fields, fn key ->
        quote do
          content_tag(:td, Map.get(element, unquote(key)))
        end
      end)

    edit_col =
      quote do
        content_tag(:td) do
          action_button(unquote(schema), :edit, id: element.id)
        end
      end

    quote do
      def table_body(unquote(schema), data, options) do
        conn = Keyword.get(options, :conn, WebCATWeb.Endpoint)

        content_tag(:tbody) do
          if Enum.count(data) > 0 do
            Enum.map(data, fn element ->
              content_tag(:tr) do
                [unquote(id_col), unquote(columns), unquote(edit_col)]
              end
            end)
          else
            content_tag(:h2, class: "subtitle") do
              "No content yet"
            end
          end
        end
      end
    end
  end

  def compile_dashboard_menu(env, resources) do
    html_ast =
      resources
      |> Enum.reduce(%{}, fn %{schema: schema}, acc ->
        # Group schemas by their parent module
        category =
          schema
          |> Module.split()
          |> Enum.at(-2)

        Map.put(acc, category, [schema | Map.get(acc, category, [])])
      end)
      |> Enum.map(fn {group, schemas} ->
        links =
          schemas
          |> Enum.sort()
          |> Enum.map(fn schema ->
            route_name = WebCATWeb.Macros.Dashboard.get_route_name(env, schema)
            title = WebCATWeb.Macros.Dashboard.get_collection_name(env, schema)

            quote do
              content_tag(:li) do
                link(unquote(title),
                  to: DashboardRoutes.unquote(:"#{route_name}_path")(conn, :index),
                  class: if(selected == unquote(route_name), do: "is-active", else: "")
                )
              end
            end
          end)

        quote do
          [
            content_tag(:p, class: "menu-label") do
              unquote(group)
            end,
            content_tag(:ul, class: "menu-list") do
              unquote(links)
            end
          ]
        end
      end)

    quote do
      def dashboard_menu(conn, selected) do
        content_tag(:aside, class: "menu") do
          [
            content_tag(:p, class: "menu-label") do
              "General"
            end,
            content_tag(:ul, class: "menu-list") do
              content_tag(:li) do
                link("Dashboard",
                  to: Routes.index_path(conn, :index),
                  class: if(selected == "dashboard", do: "is-active", else: "")
                )
              end
            end,
            unquote(html_ast)
          ]
        end
      end
    end
  end

  def compile_generate_form(env, %{schema: schema}, opts \\ []) do
    # Generate a form structure for a given schema
    # Relies on conn and changeset existing in the scope this is unquoting into

    schema_associations = schema.__schema__(:associations)
    route_name = WebCATWeb.Macros.Dashboard.get_route_name(env, schema)
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
                          (Enum.map(data, &{title_for(unquote(association.queryable), &1), &1.id})
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
                        Enum.map(data, &{title_for(unquote(association.queryable), &1), &1.id}),
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
      def generate_form(unquote(schema), changeset, opts) do
        conn = Keyword.get(opts, :conn, WebCATWeb.Endpoint)

        route =
          case changeset.data.id do
            nil -> DashboardRoutes.unquote(:"#{route_name}_path")(conn, :create)
            _ -> DashboardRoutes.unquote(:"#{route_name}_path")(conn, :edit, changeset.data.id)
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

  def table_head(%{schema: schema, table_fields: fields}, type) when type in ~w(header footer)a do
    class =
      case type do
        :header -> :thead
        :footer -> :tfoot
      end

    html =
      content_tag(class) do
        [content_tag(:th, "")] ++
          Enum.map(
            fields,
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
      def unquote(:"table_#{Atom.to_string(type)}")(unquote(schema)) do
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
