defmodule WebCATWeb.CategoryController do
  use WebCATWeb, :controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.Classroom
  alias WebCAT.Feedback.{Category, Categories}

  import Ecto.Query
  alias WebCAT.Repo

  action_fallback(WebCATWeb.FallbackController)

  @list_preload ~w(sub_categories)a
  @preload ~w(classroom parent_category)a ++ @list_preload

  def index(conn, %{"classroom_id" => classroom_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Category, :list, user),
         {:ok, classroom} <- CRUD.get(Classroom, classroom_id),
         categories <- Categories.list(classroom_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        classroom: classroom,
        categories: categories
      )
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, category} <- Categories.get(id),
         :ok <- Bodyguard.permit(Category, :show, user, category) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        category: category
      )
    end
  end

  def new(conn, %{"classroom_id" => classroom_id} = params) do
    user = Auth.current_resource(conn)

    parent_category_id =
      case Map.get(params, "parent_category_id") do
        nil ->
          nil

        id ->
          {num, _} = Integer.parse(id)
          num
      end

    with :ok <- Bodyguard.permit(Category, :create, user),
         {:ok, classroom} <- CRUD.get(Classroom, classroom_id) do
      conn
      |> render("new.html",
        user: user,
        changeset:
          Category.changeset(%Category{
            classroom_id: classroom_id,
            parent_category_id: parent_category_id
          }),
        classroom: classroom,
        selected: "classroom"
      )
    end
  end

  def create(conn, %{"category" => params}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Category, :create, user) do
      case CRUD.create(Category, params) do
        {:ok, category} ->
          conn
          |> put_flash(:info, "Category created!")
          |> redirect(to: Routes.category_path(conn, :show, category.classroom_id, category.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          {:ok, classroom} = CRUD.get(Classroom, params["classroom_id"])

          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom",
            classroom: classroom
          )
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, category} <- CRUD.get(Category, id, preload: @preload),
         :ok <- Bodyguard.permit(Category, :update, user, category) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Category.changeset(category)
      )
    end
  end

  def update(conn, %{"id" => id, "category" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, category} <- CRUD.get(Category, id, preload: @preload),
         :ok <- Bodyguard.permit(Category, :update, user, category) do
      case CRUD.update(Category, category, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Category updated!")
          |> redirect(to: Routes.category_path(conn, :show, category.classroom_id, id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "classroom",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, category} <- CRUD.get(Category, id),
         :ok <- Bodyguard.permit(Category, :delete, user, category) do
      case CRUD.delete(Category, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Category deleted successfully")
          |> redirect(to: Routes.category_path(conn, :index, category.classroom_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "Category deletion failed")
          |> redirect(to: Routes.category_path(conn, :index, category.classroom_id))
      end
    end
  end
end
