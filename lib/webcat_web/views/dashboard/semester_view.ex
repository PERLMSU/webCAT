defmodule WebCATWeb.SemesterView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.{Section, Classroom}
  alias WebCAT.CRUD

  def table(conn, semesters) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Name"),
            content_tag(:th, "Start Date"),
            content_tag(:th, "End Date"),
            content_tag(:th, "Sections"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(semesters) > 0 do
            Enum.map(semesters, fn semester ->
              content_tag(:tr) do
                [
                  content_tag(:td, semester.name),
                  content_tag(:td, Timex.format!(semester.start_date, "{M}-{D}-{YYYY}")),
                  content_tag(:td, Timex.format!(semester.end_date, "{M}-{D}-{YYYY}")),
                  content_tag(:td, Enum.count(semester.sections)),
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to: Routes.semester_path(conn, :show, semester.classroom_id, semester.id)
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to: Routes.semester_path(conn, :edit, semester.classroom_id, semester.id)
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
                "No semesters yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(%{params: %{"classroom_id" => classroom_id}} = conn, changeset) do
    classrooms =
      CRUD.list(Classroom)
      |> Enum.map(&{&1.title, &1.id})

    path =
      case changeset.data.id do
        nil -> Routes.section_path(conn, :create, classroom_id)
        id -> Routes.section_path(conn, :update, classroom_id, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Name", :name),
        form_field("Start Date", :start_date, :date),
        form_field("End Date", :start_date, :date),
        content_tag(:div, class: "field") do
          [
            label(f, :classroom_id, "Classroom"),
            content_tag(:div, class: "control") do
              select(f, :classroom_id, classrooms,
                selected:
                  if(changeset.data.classroom_id != nil) do
                    Integer.to_string(changeset.data.classroom_id)
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
