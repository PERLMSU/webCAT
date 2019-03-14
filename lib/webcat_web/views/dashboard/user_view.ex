defmodule WebCATWeb.UserView do
  use WebCATWeb, :view

  alias WebCAT.CRUD
  alias WebCAT.Rotations.Classroom

  def table(conn, users) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Email"),
            content_tag(:th, "Last Name"),
            content_tag(:th, "First Name"),
            content_tag(:th, "Roles"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          Enum.map(users, fn user ->
            content_tag(:tr) do
              [
                content_tag(:td, user.email),
                content_tag(:td, user.last_name),
                content_tag(:td, user.first_name),
                content_tag(:td) do
                  if is_list(user.performer.roles) and not Enum.empty?(user.performer.roles) do
                    Enum.map(user.performer.roles, &(&1.name))
                    |> Enum.join(",")
                  else
                    "None"
                  end
                end,
                content_tag(:td) do
                  content_tag(:div, class: "field has-addons") do
                    [
                      content_tag(:p, class: "control") do
                        icon_button("View", "eye",
                          class: "is-primary",
                          to: Routes.user_path(conn, :show, user.id)
                        )
                      end,
                      content_tag(:p, class: "control") do
                        icon_button("Edit", "wrench",
                          class: "is-primary",
                          to: Routes.user_path(conn, :edit, user.id)
                        )
                      end
                    ]
                  end
                end
              ]
            end
          end)
        end
      ]
    end
  end

  def form(conn, changeset) do
    classrooms =
      CRUD.list(Classroom)
      |> Enum.map(&{&1.name, &1.id})

    path =
      case changeset.data.id do
        nil -> Routes.user_path(conn, :create)
        id -> Routes.user_path(conn, :update, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Email", :email),
        form_field("First Name", :first_name),
        form_field("Middle Name", :middle_name),
        form_field("Last Name", :last_name),
        content_tag(:div, class: "field") do
          [
            label(f, :classrooms, "Classrooms"),
            content_tag(:p, class: "control") do
              content_tag(:div, class: "select is-multiple", style: "width:100%;") do
                multiple_select(f, :classrooms, classrooms,
                  selected:
                    if(is_list(changeset.data.classrooms),
                      do: Enum.map(changeset.data.classrooms, & &1.id),
                      else: []
                    ),
                  size: Enum.count(classrooms)
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
