defmodule WebCATWeb.ObservationView do
  use WebCATWeb, :view

  def table(conn, observations) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Type"),
            content_tag(:th, "Content"),
            content_tag(:th, "Category"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(observations) > 0 do
            Enum.map(observations, fn observation ->
              content_tag(:tr) do
                [
                  content_tag(:td, String.capitalize(observation.type)),
                  content_tag(:td, truncate(observation.content)),
                  content_tag(
                    :td,
                    link(observation.category.name,
                      to:
                        Routes.category_path(
                          conn,
                          :show,
                          observation.category.classroom_id,
                          observation.category_id
                        )
                    )
                  ),
                  content_tag(:td) do
                    content_tag(:div, class: "field has-addons") do
                      [
                        content_tag(:p, class: "control") do
                          icon_button("View", "eye",
                            class: "is-primary",
                            to:
                              Routes.observation_path(
                                conn,
                                :show,
                                observation.category_id,
                                observation.id
                              )
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to:
                              Routes.observation_path(
                                conn,
                                :edit,
                                observation.category_id,
                                observation.id
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
                "No observations yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(%{params: %{"category_id" => category_id}} = conn, changeset) do
    path =
      case changeset.data.id do
        nil -> Routes.observation_path(conn, :create, category_id)
        id -> Routes.observation_path(conn, :update, category_id, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Content", :content, :textarea),
        hidden_input(f, :category_id, value: category_id),
        content_tag(:div, class: "field") do
          [
            label(f, :type, "Type"),
            content_tag(:div, class: "control") do
              select(f, :type, Positive: "positive", Neutral: "neutral", Negative: "negative")
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
