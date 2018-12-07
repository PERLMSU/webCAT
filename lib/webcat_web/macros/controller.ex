defmodule WebCATWeb.Macros.Controller do
  @moduledoc """
  Macro to generate all necessary CRUD routes
  """

  defmacro __using__(options) do
    schema = Keyword.fetch!(options, :schema)
    item_name = Keyword.fetch!(options, :item_name)
    collection_name = Keyword.fetch!(options, :collection_name)
    routes = Keyword.get(options, :routes, ~w(index show new create edit update delete)a)
    route_name =
      Keyword.get(
        options,
        :route_name,
        String.split(item_name, " ") |> Enum.join("_") |> String.downcase()
      )
    options = [schema: schema, item_name: String.downcase(item_name), collection_name: String.downcase(collection_name), route_name: route_name]

    # Call all of the controller ast generation methods based on supplied route options
    controller_ast =
      Enum.map(routes, fn route ->
        apply(__MODULE__, route, [options])
      end)

    quote do
      use WebCATWeb, :controller

      alias WebCATWeb.Auth.Guardian.Plug, as: Auth
      alias WebCATWeb.Router.Helpers, as: Routes
      alias WebCAT.CRUD

      action_fallback(WebCATWeb.FallbackController)

      unquote(controller_ast)
    end
  end

  @doc """
  Define an index route on the controller
  """
  def index(options) do
    schema = Keyword.fetch!(options, :schema)
    collection_name = Keyword.fetch!(options, :collection_name)

    quote do
      @doc """
      Display a table of #{unquote(String.capitalize(collection_name))}
      """
      def index(conn, _params) do
        user = Auth.current_resource(conn)

        with :ok <- Bodyguard.permit(unquote(schema), :list, user),
             data <- CRUD.list(unquote(schema)) do
          render(conn, "index.html", user: user, data: data)
        end
      end
    end
  end

  @doc """
  Define a show route on the controller
  """
  def show(options) do
    schema = Keyword.fetch!(options, :schema)
    item_name = Keyword.fetch!(options, :item_name)

    quote do
      @doc """
      Display a #{unquote(String.capitalize(item_name))}
      """
      def show(conn, %{"id" => id}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :show, user, data) do
          render(conn, "show.html", user: user, data: data)
        end
      end
    end
  end

  @doc """
  Define a new route on the controller
  """
  def new(options) do
    schema = Keyword.fetch!(options, :schema)
    item_name = Keyword.fetch!(options, :item_name)

    quote do
      @doc """
      Show form for creating a #{unquote(String.capitalize(item_name))}
      """
      def new(conn, _params) do
        user = Auth.current_resource(conn)

        with :ok <- Bodyguard.permit(unquote(schema), :create, user) do
          render(conn, "form.html",
            user: user,
            changeset: unquote(schema).changeset(unquote(schema).__struct__)
          )
        end
      end
    end
  end

  @doc """
  Define a create route on the controller
  """
  def create(options) do
    schema = Keyword.fetch!(options, :schema)
    item_name = Keyword.fetch!(options, :item_name)
    route_name = Keyword.fetch!(options, :route_name)

    quote do
      @doc """
      Create a #{unquote(String.capitalize(item_name))}
      """
      def create(conn, %{unquote(item_name) => form_data}) do
        user = Auth.current_resource(conn)

        with :ok <- Bodyguard.permit(unquote(schema), :create, user) do
          case CRUD.create(unquote(schema), form_data) do
            {:ok, data} ->
              conn
              |> put_flash(:info, unquote("#{item_name} created!"))
              |> redirect(to: Routes.unquote(:"#{route_name}_path")(conn, :index))

            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "form.html", user: user, changeset: changeset)
          end
        end
      end
    end
  end

  @doc """
  Define an edit route on the controller
  """
  def edit(options) do
    schema = Keyword.fetch!(options, :schema)
    item_name = Keyword.fetch!(options, :item_name)

    quote do
      @doc """
      Show a form for editing a #{unquote(String.capitalize(item_name))}
      """
      def edit(conn, %{"id" => id}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :update, user, data) do
          render(conn, "form.html", user: user, changeset: unquote(schema).changeset(data))
        end
      end
    end
  end

  @doc """
  Define an update route on the controller
  """
  def update(options) do
    schema = Keyword.fetch!(options, :schema)
    item_name = Keyword.fetch!(options, :item_name)
    route_name = Keyword.fetch!(options, :route_name)

    quote do
      @doc """
      Do the actual update of the #{unquote(String.capitalize(item_name))}
      """
      def update(conn, %{"id" => id, unquote(item_name) => form_data}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :update, user, data) do
          case CRUD.update(unquote(schema), id, form_data) do
            {:ok, data} ->
              conn
              |> put_flash(:info, unquote("#{item_name} updated!"))
              |> redirect(to: Routes.unquote(:"#{route_name}_path")(conn, :index))

            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "form.html", user: user, changeset: changeset)
          end
        end
      end
    end
  end

  @doc """
  Define a delete route on the controller
  """
  def delete(options) do
    schema = Keyword.fetch!(options, :schema)
    item_name = Keyword.fetch!(options, :item_name)
    route_name = Keyword.fetch!(options, :route_name)

    quote do
      @doc """
      Delete a #{String.capitalize(unquote(item_name))}
      """
      def delete(conn, %{"id" => id}) do
        user = Auth.current_resource(conn)

        with {:ok, data} <- CRUD.get(unquote(schema), id),
             :ok <- Bodyguard.permit(unquote(schema), :delete, user, data),
             {:ok, data} <- CRUD.delete(unquote(schema), id) do
          conn
          |> put_flash(:info, unquote("#{item_name} deleted!"))
          |> redirect(to: Routes.unquote(:"#{route_name}_path")(conn, :index))
        end
      end
    end
  end
end
