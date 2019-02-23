defmodule WebCATWeb.RotationGroupView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.Rotation
  alias WebCAT.CRUD

  def table(conn, groups) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Number"),
            content_tag(:th, "Description"),
            content_tag(:th, "Students"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if not Enum.empty?(groups) do
            Enum.map(groups, fn group ->
              content_tag(:tr) do
                [
                  content_tag(:td, group.number),
                  content_tag(:td, truncate(group.description)),
                  content_tag(:td, Enum.count(group.users)),
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to:
                              Routes.rotation_group_path(conn, :show, group.rotation_id, group.id)
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to:
                              Routes.rotation_group_path(conn, :edit, group.rotation_id, group.id)
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
                "No rotation groups yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(%{params: %{"rotation_id" => rotation_id}} = conn, changeset) do
    rotations =
      CRUD.list(Rotation)
      |> Enum.map(&{&1.number, &1.id})

    path =
      case changeset.data.id do
        nil -> Routes.rotation_group_path(conn, :create, rotation_id)
        id -> Routes.rotation_group_path(conn, :update, rotation_id, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Number", :number),
        form_field("Description", :description, :textarea),
        content_tag(:div, class: "field") do
          [
            label(f, :rotation_id, "Rotation"),
            content_tag(:div, class: "control") do
              select(f, :rotation_id, rotations,
                selected:
                  if(changeset.data.rotation_id != nil) do
                    Integer.to_string(changeset.data.rotation_id)
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
