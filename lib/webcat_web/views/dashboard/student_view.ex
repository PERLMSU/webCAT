defmodule WebCATWeb.StudentView do
  use WebCATWeb, :view

  alias WebCAT.CRUD
  alias WebCAT.Rotations.Section

  def table(conn, students) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "First Name"),
            content_tag(:th, "Last Name"),
            content_tag(:th, "Email"),
            content_tag(:th, "Description"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(students) > 0 do
            Enum.map(students, fn student ->
              content_tag(:tr) do
                [
                  content_tag(:td, student.first_name),
                  content_tag(:td, student.last_name),
                  content_tag(:td, student.email),
                  content_tag(:td) do
                    cond do
                      student.description == nil ->
                        ""

                      String.length(student.description) > 25 ->
                        String.slice(student.description, 0..25) <> "..."

                      true ->
                        student.description
                    end
                  end,
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to: Routes.student_path(conn, :show, student.id)
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to: Routes.student_path(conn, :edit, student.id)
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
                "No students yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(conn, changeset) do
    sections =
      CRUD.list(Section)
      |> Enum.map(&{&1.number, &1.id})

    path =
      case changeset.data.id do
        nil -> Routes.student_path(conn, :create)
        id -> Routes.student_path(conn, :update, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("First Name", :first_name),
        form_field("Middle Name", :middle_name),
        form_field("Last Name", :last_name),
        form_field("Email", :email),
        form_field("Description", :description, :textarea),
        content_tag(:div, class: "field") do
          [
            label(f, :sections, "Sections"),
            content_tag(:p, class: "control") do
              content_tag(:span, class: "select is-multiple") do
                multiple_select(f, :sections, sections,
                  selected:
                    if(is_list(changeset.data.sections),
                      do: Enum.map(changeset.data.sections, & &1.id),
                      else: []
                    ),
                  size: Enum.count(sections)
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
