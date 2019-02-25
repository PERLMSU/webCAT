defmodule WebCATWeb.SharedView do
  use WebCATWeb, :view

  def menu_entry(entry, icon, to, selected) do
    content_tag(:li) do
      content_tag(:a, class: (if selected == true, do: "is-active", else: ""), href: to) do
        [
          content_tag(:span, class: "icon") do
            content_tag(:i, "", class: "far fa-#{icon}")
          end,
          content_tag(:span, entry)
        ]
      end
    end
  end
end
