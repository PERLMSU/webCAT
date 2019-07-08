defmodule WebCATWeb.ImportController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.ImportView
  alias WebCAT.Import.Registry

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, _params) do
    permissions do
      has_role(:admin)
    end

    conn
    |> put_status(200)
    |> put_view(ImportView)
    |> render("list.json", results: Registry.results(), queue: Registry.queue())
  end

  def create(conn, _user, %{"import" => %Plug.Upload{path: path}}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()} do
      Registry.add(path)

      conn
      |> put_status(201)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to import data")}

      {:error, _} = it ->
        it
    end
  end
end
