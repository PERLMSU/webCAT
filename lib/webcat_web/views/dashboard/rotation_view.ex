defmodule WebCATWeb.RotationView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.Section
  alias WebCAT.CRUD

  def table(conn, rotations) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Number"),
            content_tag(:th, "Start Date"),
            content_tag(:th, "End Date"),
            content_tag(:th, "Description"),
            content_tag(:th, "Rotation Groups"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(rotations) > 0 do
            Enum.map(rotations, fn rotation ->
              content_tag(:tr) do
                [
                  content_tag(:td, rotation.number),
                  content_tag(:td, Timex.format!(rotation.start_date, "{M}-{D}-{YYYY}")),
                  content_tag(:td, Timex.format!(rotation.end_date, "{M}-{D}-{YYYY}")),
                  content_tag(:td, truncate(rotation.description)),
                  content_tag(:td, Enum.count(rotation.rotation_groups)),
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to: Routes.rotation_path(conn, :show, rotation.section_id, rotation.id)
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to: Routes.rotation_path(conn, :edit, rotation.section_id, rotation.id)
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
                "No rotations yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(%{params: %{"section_id" => section_id}} = conn, changeset) do
    sections =
      CRUD.list(Section)
      |> Enum.map(&{&1.number, &1.id})

    path =
      case changeset.data.id do
        nil -> Routes.rotation_path(conn, :create, section_id)
        id -> Routes.rotation_path(conn, :update, section_id, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Number", :number),
        form_field("Description", :description, :textarea),
        form_field("Start Date", :start_date, :date),
        form_field("End Date", :end_date, :date),
        content_tag(:div, class: "field") do
          [
            label(f, :section_id, "Section"),
            content_tag(:div, class: "control") do
              select(f, :section_id, sections,
                selected:
                  if(changeset.data.section_id != nil) do
                    Integer.to_string(changeset.data.section_id)
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
