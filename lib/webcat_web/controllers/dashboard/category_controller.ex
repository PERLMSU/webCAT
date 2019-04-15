defmodule WebCATWeb.CategoryController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Feedback.{Category, Categories}
  alias WebCAT.Rotations.Classrooms

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"classroom_id" => classroom_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- Classrooms.get(classroom_id),
         categories <- Categories.list(classroom_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        categories: categories,
        classroom: classroom
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, category} <- Categories.get(id) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        category: category
      )
    end
  end

  def new(conn, user, %{"classroom_id" => classroom_id} = params) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- Classrooms.get(classroom_id) do
      conn
      |> render("new.html",
        user: user,
        changeset:
          Category.changeset(%Category{
            classroom_id: classroom_id,
            parent_category_id: Map.get(params, "parent_category_id")
          }),
        selected: "classroom",
        classroom: classroom
      )
    end
  end

  def create(conn, user, %{"category" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Category, params) do
        {:ok, category} ->
          conn
          |> put_flash(:info, "Category created!")
          |> redirect(to: Routes.category_path(conn, :show, category.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom"
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, category} <- Categories.get(id) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Category.changeset(category),
        classroom: category.classroom
      )
    end
  end

  def update(conn, user, %{"id" => id, "category" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, category} <- Categories.get(id) do
      case CRUD.update(Category, category, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Category updated!")
          |> redirect(to: Routes.category_path(conn, :show, id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "classroom",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, category} <- CRUD.get(Category, id) do
      case CRUD.delete(Category, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Category deleted successfully")
          |> redirect(to: Routes.category_path(conn, :index, classroom_id: category.classroom_id))

        {:error, %Ecto.Changeset{}} ->
          conn
          |> put_flash(:error, "Category deletion failed")
          |> redirect(to: Routes.category_path(conn, :index, classroom_id: category.classroom_id))
      end
    end
  end
end
