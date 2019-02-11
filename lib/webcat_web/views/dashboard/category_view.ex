defmodule WebCATWeb.CategoryView do
  use WebCATWeb, :view

  alias WebCAT.CRUD
  alias WebCAT.Feedback.Category

  def table(conn, categories) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Name"),
            content_tag(:th, "Description"),
            content_tag(:th, "Sub Categories"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(categories) > 0 do
            Enum.map(categories, fn category ->
              content_tag(:tr) do
                [
                  content_tag(:td, category.name),
                  content_tag(:td) do
                    truncate(category.description)
                  end,
                  content_tag(:td, Enum.count(category.sub_categories)),
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to:
                              Routes.category_path(
                                conn,
                                :show,
                                category.classroom_id,
                                category.id
                              )
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to:
                              Routes.category_path(
                                conn,
                                :edit,
                                category.classroom_id,
                                category.id
                              )
                          )
                        end
                      ]
                    end
                  end
                ]
              end
            end)
          else
            content_tag(:tr) do
              content_tag(:td) do
                "No categories yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(conn, changeset) do
    classroom_id = changeset.data.classroom_id

    path =
      case changeset.data.id do
        nil -> Routes.category_path(conn, :create, classroom_id)
        id -> Routes.category_path(conn, :update, classroom_id, id)
      end

    categories =
      CRUD.list(Category, where: [classroom_id: classroom_id])
      |> Enum.map(&{&1.name, &1.id})

    form_for(changeset, path, fn f ->
      [
        form_field("Name", :name),
        form_field("Description", :description, :textarea),
        hidden_input(f, :classroom_id, value: classroom_id),
        content_tag(:div, class: "field") do
          [
            label(f, :parent_category_id, "Parent Category"),
            content_tag(:div, class: "control") do
              content_tag(:div, class: "select") do
                select(f, :parent_category_id, categories,
                  selected:
                    if(changeset.data.parent_category_id != nil) do
                      Integer.to_string(changeset.data.parent_category_id)
                    end,
                  prompt: "None"
                )
              end
            end
          ]
        end,
        content_tag(:div, class: "field") do
          content_tag(:div, class: "control") do
            submit("Submit", class: "button is-primary")
          end
        end
      ]
    end)
  end
end
