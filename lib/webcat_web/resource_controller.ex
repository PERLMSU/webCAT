defmodule WebCATWeb.ResourceController do
  @module_doc """
  Gets you all of the basic CRUD routes necessary for main functionality.
  Relationship routes are up to you to define.
  """

  defmacro __using__(opts \\ []) do
    {schema, opts} = Keyword.pop(opts, :schema)
    {view, opts} = Keyword.pop(opts, :view)
    {type, opts} = Keyword.pop(opts, :type)
    {filter, opts} = Keyword.pop(opts, :filter)
    {sort, opts} = Keyword.pop(opts, :sort)
    {roles, _opts} = Keyword.pop(opts, :roles, ~w(admin)a)

    permissions = Enum.map(roles, fn role ->
      quote do
        has_role(unquote(role))
      end
    end)

    quote do
      use WebCATWeb, :authenticated_controller

      alias WebCAT.CRUD

      action_fallback(WebCATWeb.FallbackController)

      plug JSONAPI.QueryParser,
        filter: unquote(filter),
        sort: unquote(sort),
        view: unquote(view)

      def index(conn, _user, _params) do
        query =
          conn.assigns.jsonapi_query
          |> Map.take(~w(include fields sort filter)a)
          |> Map.update!(:fields, &Map.get(&1, unquote(String.to_atom(type))))
          |> Map.to_list()

        conn
        |> put_status(200)
        |> put_view(unquote(view))
        |> render("index.json", %{data: CRUD.list(unquote(schema), query)})
      end

      def show(conn, _user, %{"id" => id}) do
        query =
          conn.assigns.jsonapi_query
          |> Map.take(~w(include fields)a)
          |> Map.update!(:fields, &Map.get(&1, unquote(String.to_atom(type))))
          |> Map.to_list()

        with {:ok, data} <- CRUD.get(unquote(schema), id, query) do
          conn
          |> put_status(:ok)
          |> put_view(unquote(view))
          |> render("show.json", %{data: data})
        end
      end

      def create(conn, _user, params) do
        permissions do
          unquote(permissions)
        end

        with {:auth, :ok} <- {:auth, is_authorized?()},
             {:ok, data} <- CRUD.create(unquote(schema), params) do
          conn
          |> put_status(:created)
          |> put_view(unquote(view))
          |> render("show.json", %{data: data})
        else
          {:auth, _} ->
            {:error, :forbidden, dgettext("errors", unquote("Not authorized to create #{type}"))}

          {:error, _} = it ->
            it
        end
      end

      def update(conn, _user, %{"id" => id} = params) do
        permissions do
          unquote(permissions)
        end

        with {:auth, :ok} <- {:auth, is_authorized?()},
             {:ok, updated} <- CRUD.update(unquote(schema), id, params) do
          conn
          |> put_status(:ok)
          |> put_view(unquote(view))
          |> render("show.json", %{data: updated})
        else
          {:auth, _} ->
            {:error, :forbidden, dgettext("errors", unquote("Not authorized to update #{type}"))}

          {:error, _} = it ->
            it
        end
      end

      def delete(conn, _user, %{"id" => id}) do
        permissions do
          unquote(permissions)
        end

        with {:auth, :ok} <- {:auth, is_authorized?()},
             {:ok, _deleted} <- CRUD.delete(unquote(schema), id) do
          send_resp(conn, :no_content, "")
        else
          {:auth, _} ->
            {:error, :forbidden, dgettext("errors", unquote("Not authorized to delete #{type}"))}

          {:error, _} = it ->
            it
        end
      end
    end
  end
end
