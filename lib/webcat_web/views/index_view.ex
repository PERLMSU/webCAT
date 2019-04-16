defmodule WebCATWeb.IndexView do
  use WebCATWeb, :view



  @external_resource changelog_path = Path.join(File.cwd!(), "./CHANGELOG.md")
  @changelog_path changelog_path

  defmacro changes_html() do
    raw_changelog_html =
      @changelog_path
      |> File.read!()
      |> Earmark.as_html!()

    quote do
      unquote(raw_changelog_html)
    end
  end
end
