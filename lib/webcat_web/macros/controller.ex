defmodule WebCATWeb.Macros.Controller do
  @moduledoc """
  Macro to generate all necessary CRUD routes
  """

  def compile_controller(env, resources) do
    Enum.map(resources, fn %{schema: schema} ->
      route_name = WebCATWeb.Macros.Dashboard.get_route_name(env, schema)

      route_ast =
        Enum.map(~w(index show new create edit update delete import import_submit)a, fn route ->
          apply(__MODULE__, route, [env, schema, route_name])
        end)

      quote do
        defmodule unquote(
                    Module.concat([env.module, Controller, List.last(Module.split(schema))])
                  ) do
          use Phoenix.Controller, namespace: WebCATWeb
          import Plug.Conn
          import WebCATWeb.Gettext
          alias WebCATWeb.Dashboard.Router.Helpers, as: Routes
          alias WebCATWeb.Auth.Guardian.Plug, as: Auth
          alias WebCAT.CRUD

          action_fallback(WebCATWeb.FallbackController)

          unquote(route_ast)
        end
      end
    end)
  end

  @doc """
  Define an index route on the controller
  """
  def index(env, schema, _route_name) do
    quote do
      def index(conn, _params) do
        user = Auth.current_resource(conn)

        with :ok <- Bodyguard.permit(unquote(schema), :list, user),
             data <- CRUD.list(unquote(schema)) do
          conn
          |> put_view(unquote(env.module).View)
          |> render("index.html",
            user: user,
            data: data,
            schema: unquote(schema)
          )
        end
      end
    end
  end

  @doc """
  Define a show route on the controller
  """
  def show(env, schema, _route_name) do
    quote do
      def show(conn, %{"id" => id}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :show, user, data) do
          conn
          |> put_view(unquote(env.module).View)
          |> render("show.html",
            user: user,
            data: data,
            schema: unquote(schema)
          )
        end
      end
    end
  end

  @doc """
  Define a new route on the controller
  """
  def new(env, schema, _route_name) do
    quote do
      def new(conn, _params) do
        user = Auth.current_resource(conn)

        with :ok <- Bodyguard.permit(unquote(schema), :create, user) do
          conn
          |> put_view(unquote(env.module).View)
          |> render("form.html",
            user: user,
            changeset: unquote(schema).changeset(unquote(schema).__struct__),
            schema: unquote(schema)
          )
        end
      end
    end
  end

  @doc """
  Define a create route on the controller
  """
  def create(env, schema, route_name) do
    quote do
      def create(conn, %{unquote(route_name) => form_data}) do
        user = Auth.current_resource(conn)

        with :ok <- Bodyguard.permit(unquote(schema), :create, user) do
          case CRUD.create(unquote(schema), form_data) do
            {:ok, data} ->
              conn
              |> put_flash(:info, unquote("#{String.capitalize(route_name)} created!"))
              |> redirect(to: Routes.unquote(:"#{route_name}_path")(conn, :index))

            {:error, %Ecto.Changeset{} = changeset} ->
              conn
              |> put_view(unquote(env.module).View)
              |> render("form.html",
                user: user,
                changeset: changeset,
                schema: unquote(schema)
              )
          end
        end
      end
    end
  end

  @doc """
  Define an edit route on the controller
  """
  def edit(env, schema, _route_name) do
    quote do
      def edit(conn, %{"id" => id}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :update, user, data) do
          conn
          |> put_view(unquote(env.module).View)
          |> render("form.html",
            user: user,
            changeset: unquote(schema).changeset(data),
            schema: unquote(schema)
          )
        end
      end
    end
  end

  @doc """
  Define an update route on the controller
  """
  def update(env, schema, route_name) do
    quote do
      def update(conn, %{"id" => id, unquote(route_name) => form_data}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :update, user, data) do
          case CRUD.update(unquote(schema), id, form_data) do
            {:ok, data} ->
              conn
              |> put_flash(:info, unquote("#{String.capitalize(route_name)} updated!"))
              |> redirect(to: Routes.unquote(:"#{route_name}_path")(conn, :index))

            {:error, %Ecto.Changeset{} = changeset} ->
              conn
              |> put_view(unquote(env.module).View)
              |> render("form.html",
                user: user,
                changeset: changeset,
                schema: unquote(schema)
              )
          end
        end
      end
    end
  end

  @doc """
  Define a delete route on the controller
  """
  def delete(_env, schema, route_name) do
    quote do
      def delete(conn, %{"id" => id}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :delete, user, data),
             {:ok, data} <- CRUD.delete(unquote(schema), id) do
          conn
          |> put_flash(:info, unquote("#{String.capitalize(route_name)} deleted!"))
          |> redirect(to: Routes.unquote(:"#{route_name}_path")(conn, :index))
        end
      end
    end
  end

  def import(_env, _schema, _route_name) do
    quote do
      def import(_conn, _assigns) do
      end
    end
  end

  def import_submit(_env, _schema, _route_name) do
    quote do
      def import_submit(_conn, _assigns) do
      end
    end
  end
end
