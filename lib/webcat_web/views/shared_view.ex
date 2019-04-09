defmodule WebCATWeb.SharedView do
  use WebCATWeb, :view

  def menu_entry(entry, icon, to, selected) do
    content_tag(:a, class: if(selected == true, do: "active item", else: "item"), href: to) do
      [
        entry,
        content_tag(:i, "", class: "icon far fa-#{icon}")
      ]
    end
  end

  @external_resource Path.join(File.cwd!(), "./lib")
  defmacro build_info do
    # Timex has to be started at compile time for tzdata
    {:ok, _} = Application.ensure_all_started(:timex)

    build_date =
      Timex.now("America/Detroit")
      |> Timex.format!("{YYYY}-{M}-{D} at {h12}:{m}{am} {Zabbr}")

    version = Mix.Project.config()[:version]

    quote do
      {unquote(version), unquote(build_date)}
    end
  end
end
