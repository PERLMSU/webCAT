defmodule WebCATWeb.ClassroomView do
  use WebCATWeb, :view

  def table(conn, classrooms) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Course Code"),
            content_tag(:th, "Title"),
            content_tag(:th, "Description"),
            content_tag(:th, "Semesters"),
            content_tag(:th, "Users"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(classrooms) > 0 do
            Enum.map(classrooms, fn classroom ->
              content_tag(:tr) do
                [
                  content_tag(:td, classroom.course_code),
                  content_tag(:td, classroom.title),
                  content_tag(:td) do
                    cond do
                      classroom.description == nil ->
                        ""

                      String.length(classroom.description) > 25 ->
                        String.slice(classroom.description, 0..25) <> "..."

                      true ->
                        classroom.description
                    end
                  end,
                  content_tag(:td, Enum.count(classroom.semesters)),
                  content_tag(:td, Enum.count(classroom.users)),
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to: Routes.classroom_path(conn, :show, classroom.id)
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to: Routes.classroom_path(conn, :edit, classroom.id)
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
                "No classrooms yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(conn, changeset) do
    path =
      case changeset.data.id do
        nil -> Routes.classroom_path(conn, :create)
        id -> Routes.classroom_path(conn, :update, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Course Code", :course_code),
        form_field("Title", :title),
        form_field("Description", :description, :textarea),
        content_tag(:div, class: "field") do
          content_tag(:div, class: "control") do
            submit("Submit", class: "button is-primary")
          end
        end
      ]
    end)
  end
end
