defmodule WebCATWeb.ImportView do
  use WebCATWeb, :view

  alias WebCATWeb.Import.{Status, Error}

  def render("list.json", %{results: results, queue: queue}) do
    %{results: render_many(results, __MODULE__, "result.json"), queue: queue}
  end

  def render("result.json", %{import: %Status{} = import_}) do
    import_
    |> Map.from_struct()
  end
end
