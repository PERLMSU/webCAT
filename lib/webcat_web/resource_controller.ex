defmodule WebCATWeb.ResourceController do
  @moduledoc """
  Gets you all of the basic CRUD routes necessary for main functionality.
  Relationship routes are up to you to define.
  """

  defmacro __using__(opts \\ []) do
    {schema, opts} = Keyword.pop(opts, :schema)
    {view, opts} = Keyword.pop(opts, :view)
    {type, opts} = Keyword.pop(opts, :type)
    {filter, opts} = Keyword.pop(opts, :filter)
    {sort, opts} = Keyword.pop(opts, :sort)
    {actions, opts} = Keyword.pop(opts, :actions, ~w(index show create update delete)a)
    {roles, _opts} = Keyword.pop(opts, :roles, ~w(admin))

    quote do
      use WebCATWeb, :authenticated_controller

      alias WebCAT.CRUD

      action_fallback(WebCATWeb.FallbackController)

      plug JSONAPI.QueryParser,
        filter: unquote(filter),
        sort: unquote(sort),
        view: unquote(view)

      @actions unquote(actions)

      if :index in @actions do
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
      end

      if :show in @actions do
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
      end

      if :create in @actions do
        def create(conn, user, params) do
          with {:auth, true} <- {:auth, user.role in unquote(roles)},
               {:ok, data} <- CRUD.create(unquote(schema), params) do
            conn
            |> put_status(:created)
            |> put_view(unquote(view))
            |> render("show.json", %{data: data})
          else
            {:auth, _} ->
              {:error, :forbidden,
               dgettext("errors", unquote("Not authorized to create #{type}"))}

            {:error, _} = it ->
              it
          end
        end
      end

      if :update in @actions do
        def update(conn, user, %{"id" => id} = params) do
          with {:auth, true} <- {:auth, user.role in unquote(roles)},
               {:ok, updated} <- CRUD.update(unquote(schema), id, params) do
            conn
            |> put_status(:ok)
            |> put_view(unquote(view))
            |> render("show.json", %{data: updated})
          else
            {:auth, _} ->
              {:error, :forbidden,
               dgettext("errors", unquote("Not authorized to update #{type}"))}

            {:error, _} = it ->
              it
          end
        end
      end

      if :delete in @actions do
        def delete(conn, user, %{"id" => id}) do
          with {:auth, true} <- {:auth, user.role in unquote(roles)},
               {:ok, _deleted} <- CRUD.delete(unquote(schema), id) do
            send_resp(conn, :no_content, "")
          else
            {:auth, _} ->
              {:error, :forbidden,
               dgettext("errors", unquote("Not authorized to delete #{type}"))}

            {:error, _} = it ->
              it
          end
        end
      end
    end
  end
end
