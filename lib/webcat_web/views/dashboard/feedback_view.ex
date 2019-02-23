defmodule WebCATWeb.FeedbackView do
  use WebCATWeb, :view

  def table(conn, feedback) do
    content_tag(:table, class: "table") do
      [
        content_tag(:thead) do
          [
            content_tag(:th, "Content"),
            content_tag(:th, "Observation"),
            content_tag(:th, "")
          ]
        end,
        content_tag(:tbody) do
          if Enum.count(feedback) > 0 do
            Enum.map(feedback, fn item ->
              content_tag(:tr) do
                [
                  content_tag(:td, truncate(item.content)),
                  content_tag(
                    :td,
                    link(truncate(item.observation.content, 10),
                      to:
                        Routes.observation_path(
                          conn,
                          :show,
                          item.observation.category_id,
                          item.observation_id
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
                              Routes.feedback_path(
                                conn,
                                :show,
                                item.observation_id,
                                item.id
                              )
                          )
                        end,
                        content_tag(:p, class: "control") do
                          icon_button("Edit", "wrench",
                            class: "is-primary",
                            to:
                              Routes.feedback_path(
                                conn,
                                :edit,
                                item.observation_id,
                                item.id
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
                "No feedback yet"
              end
            end
          end
        end
      ]
    end
  end

  def form(%{params: %{"observation_id" => observation_id}} = conn, changeset) do
    path =
      case changeset.data.id do
        nil -> Routes.feedback_path(conn, :create, observation_id)
        id -> Routes.feedback_path(conn, :update, observation_id, id)
      end

    form_for(changeset, path, fn f ->
      [
        form_field("Content", :content, :textarea),
        hidden_input(f, :observation_id, value: observation_id),
        content_tag(:div, class: "field") do
          content_tag(:div, class: "control") do
            submit("Submit", class: "button is-primary")
          end
        end
      ]
    end)
  end
end
