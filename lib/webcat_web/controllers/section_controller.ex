defmodule WebCATWeb.SectionController do
  alias WebCATWeb.SectionView
  alias WebCAT.Rotations.Section
  alias WebCAT.Import.Students, as: Import


  use WebCATWeb.ResourceController,
    schema: Section,
    view: SectionView,
    type: "section",
    filter: ~w(number semester_id),
    sort: ~w(number semester_id inserted_at updated_at)


  def import(conn, _user, %{"id" => id, "file" => %{path: path}}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _section} <- CRUD.get(Section, id),
         :ok <- Import.import(id, path) do
      conn
      |> put_status(201)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to import data")}
      {:error, _} = it -> it
    end
  end
end
