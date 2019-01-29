defmodule WebCATWeb.SectionView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.Semester
  alias WebCAT.CRUD

  def table(conn, sections) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Number"),
            content_tag(:th, "Description"),
            content_tag(:th, "Rotations"),
            content_tag(:th, "Users"),
            content_tag(:th, "Students"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(sections) > 0 do
            Enum.map(sections, fn section ->
              content_tag(:tr) do
                [
                  content_tag(:td, section.number),
                  content_tag(:td) do
                    cond do
                      section.description == nil ->
                        ""

                      String.length(section.description) > 25 ->
                        String.slice(section.description, 0..25) <> "..."

                      true ->
                        section.description
                    end
                  end,
                  content_tag(:td, Enum.count(section.rotations)),
                  content_tag(:td, Enum.count(section.users)),
                  content_tag(:td, Enum.count(section.students)),
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to: Routes.section_path(conn, :show, section.semester_id, section.id)
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to: Routes.section_path(conn, :edit, section.semester_id, section.id)
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
                "No sections yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(%{params: %{"semester_id" => semester_id}} = conn, changeset) do
    semesters =
      CRUD.list(Semester)
      |> Enum.map(&{&1.title, &1.id})

    path =
      case changeset.data.id do
        nil -> Routes.section_path(conn, :create, semester_id)
        id -> Routes.section_path(conn, :update, semester_id, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Number", :number),
        form_field("Description", :description, :textarea),
        content_tag(:div, class: "field") do
          [
            label(f, :semester_id, "Semester"),
            content_tag(:div, class: "control") do
              select(f, :semester_id, semesters,
                selected:
                  if(changeset.data.semester_id != nil) do
                    Integer.to_string(changeset.data.semester_id)
                  end
              )
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
