defmodule WebCATWeb.SectionController do
  alias WebCATWeb.{SectionView, UserView}
  alias WebCAT.Rotations.Section
  alias WebCAT.Import.Students, as: Import


  use WebCATWeb.ResourceController,
    schema: Section,
    view: SectionView,
    type: "section",
    filter: ~w(number semester_id classroom_id),
    sort: ~w(number semester_id classroom_id inserted_at updated_at)


  def import(conn, user, %{"id" => id, "file" => %{path: path}}) do
    with {:auth, true} <- {:auth, user.role in ~w(admin)},
         {:ok, _section} <- CRUD.get(Section, id),
         {:ok, imported} <- Import.import(id, path) do
      conn
      |> put_status(201)
      |> put_view(UserView)
      |> render("index.json", %{data: imported})
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to import data")}
      {:error, _} = it -> it
    end
  end
end
